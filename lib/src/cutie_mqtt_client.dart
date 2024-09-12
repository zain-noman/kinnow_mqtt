import 'dart:async';
import 'package:async/async.dart';
import 'package:cutie_mqtt/cutie_mqtt.dart';
import 'package:cutie_mqtt/src/conn_ack_packet.dart';
import 'package:cutie_mqtt/src/disconnect_packet.dart';
import 'package:cutie_mqtt/src/mqtt_fixed_header.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';
import 'package:cutie_mqtt/src/publish_packet.dart';
import 'package:cutie_mqtt/src/resettable_periodic_timer.dart';

class MqttActiveConnectionState {
  final ResettablePeriodicTimer pingTimer;
  final StreamQueue<int> streamQ;
  final Completer<Null> pingRespTimeoutCompleter = Completer<Null>();

  MqttActiveConnectionState(this.pingTimer, this.streamQ);

  void dispose() {
    pingTimer.stop(dispose: true);
  }
}

class CutieMqttClient implements TopicAliasManager {
  final MqttNetworkConnection networkConnection;
  late String clientId;
  final StreamController<MqttEvent> _eventController =
      StreamController<MqttEvent>.broadcast();

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  MqttActiveConnectionState? _activeConnectionState;

  bool get isConnected => _activeConnectionState != null;

  bool _disconnectFlag = false;
  final StreamController<bool> _disconnectFlagStream =
      StreamController<bool>.broadcast();
  DisconnectPacket? _txDisconnectPacket;

  CutieMqttClient(this.networkConnection, {String? initClientId}) {
    clientId =
        initClientId ?? "cutie_mqtt_${DateTime.now().millisecondsSinceEpoch}";
    _disconnectFlagStream.onListen = () {
      if (_disconnectFlag == true) {
        _disconnectFlagStream.add(true);
      }
    };
  }

  Stream<MqttEvent> begin(ConnectPacket connPkt) {
    _eventController.onListen = () {
      _internalLoop(connPkt);
    };
    // TODO: onCancel
    return _eventController.stream;
  }

  Future<(bool exit, StreamQueue<int>? streamQ)> _connect(
      ConnectPacket connPkt) async {
    final byteStream = await networkConnection.connect();
    if (byteStream == null) {
      _eventController.add(NetworkConnectionFailure());
      return (false, null);
    }
    print("network Connected");
    // byteStream.listen((event) => print("socket data: $event"),
    //     onDone: () => print("stream finished"));
    networkConnection.transmit(connPkt.toBytes(clientId));
    print("connect sent");

    final streamQ = StreamQueue<int>(byteStream);
    final connackFixedHdr = await Future.any(
      [Future.delayed(const Duration(seconds: 3), () => null), streamQ.take(2)],
    );
    print("$connackFixedHdr");
    if (connackFixedHdr == null) {
      _eventController.add(ConnackTimedOut());
      return (false, null);
    }

    // handle case where the stream ends before 2 bytes
    if (connackFixedHdr.length != 2) {
      _eventController.add(NetworkEnded());
      return (false, null);
    }

    final fixedHdr = MqttFixedHeader.fromBytes(connackFixedHdr);
    if (fixedHdr!.data.packetType != MqttPacketType.connack) {
      _eventController
          .add(MalformedPacket(connackFixedHdr, message: "expected CONNACK"));
      return (true, null);
    }
    final remLen = fixedHdr.data.remainingLength;

    final connackBytes = await Future.any([
      streamQ.take(remLen),
      Future.delayed(const Duration(seconds: 3), () => null)
    ]);
    if (connackBytes == null) {
      _eventController.add(ConnackTimedOut());
      return (false, null);
    }
    if (connackBytes.length != remLen) {
      _eventController.add(NetworkEnded());
      return (false, null);
    }

    final connAck = ConnAckPacket.fromBytes(connackBytes);
    if (connAck == null) {
      _eventController.add(MalformedPacket(connackBytes));
      return (true, null);
    }
    _eventController.add(ConnAckEvent(connAck));
    if (connAck.connectReasonCode != ConnectReasonCode.success) {
      return (true, null);
    }
    return (false, streamQ);
  }

  Future<void> _internalLoop(ConnectPacket connPkt) async {
    while (true) {
      final (exit, streamQ) = await _connect(connPkt);

      if (streamQ == null) {
        if (exit) {
          // connection failed but we shouldn't retry
          _eventController
              .add(ShutDown(ShutdownType.connectionNotPossible, null));
          break;
        } else {
          await Future.any([
            Future.delayed(Duration(seconds: connPkt.keepAliveSeconds)),
            _disconnectFlagStream.stream.first
          ]);
          if (_disconnectFlag) {
            _eventController.add(
                ShutDown(ShutdownType.clientInitiatedNetworkUnavailable, null));
            break;
          }
          continue;
        }
      }

      assert(_activeConnectionState == null);

      _activeConnectionState = MqttActiveConnectionState(
        ResettablePeriodicTimer(
          time: Duration(seconds: connPkt.keepAliveSeconds),
          callback: _sendPingReq,
        ),
        streamQ,
      );
      _activeConnectionState!.pingTimer.start();
      _connectionStatusController.add(true);
      final reconnect = await _useActiveNetworkConnection();
      _connectionStatusController.add(false);
      _activeConnectionState!.dispose();
      _activeConnectionState = null;

      if (!reconnect) break;
      connPkt.cleanStart = false;
    }
    await _dispose();
  }

  bool _pingRespReceived = false;

  void _sendPingReq() {
    networkConnection
        .transmit(MqttFixedHeader(MqttPacketType.pingreq, 0, 0).toBytes());
    _pingRespReceived = false;
    _eventController.add(PingReqSent());
    Timer(
      const Duration(seconds: 3),
      () {
        if (_pingRespReceived) return;
        _eventController.add(PingRespNotReceived());
        _activeConnectionState?.pingRespTimeoutCompleter.complete(null);
      },
    );
  }

  //returns whether to reconnect or not
  Future<bool> _useActiveNetworkConnection() async {
    assert(_activeConnectionState != null);
    while (true) {
      final fixedHeaderBytes = await Future.any([
        _activeConnectionState!.streamQ.take(2),
        _activeConnectionState!.pingRespTimeoutCompleter.future,
        _disconnectFlagStream.stream.first.then(
          (value) => null,
        )
      ]);
      if (_disconnectFlag) {
        _eventController
            .add(ShutDown(ShutdownType.clientInitiated, _txDisconnectPacket));
        break;
      }
      // ping response not received
      if (fixedHeaderBytes == null) {
        return true;
      }

      // connection closed
      if (fixedHeaderBytes.length != 2) {
        return true;
      }
      final fixedHeaderParse = MqttFixedHeader.fromBytes(fixedHeaderBytes);
      if (fixedHeaderParse == null) {
        return true;
      }
      final packetBytes = await Future.any([
        _activeConnectionState!.streamQ
            .take(fixedHeaderParse.data.remainingLength),
        _activeConnectionState!.pingRespTimeoutCompleter.future,
        _disconnectFlagStream.stream.first.then(
          (value) => null,
        )
      ]);
      if (_disconnectFlag) {
        _eventController
            .add(ShutDown(ShutdownType.clientInitiated, _txDisconnectPacket));
        break;
      }
      //ping response timeout
      if (packetBytes == null) return true;

      if (packetBytes.length != fixedHeaderParse.data.remainingLength) {
        return true;
      }
      switch (fixedHeaderParse.data.packetType) {
        case MqttPacketType.publish:
        // TODO: Handle this case.
        case MqttPacketType.puback:
        // TODO: Handle this case.
        case MqttPacketType.pubrec:
        // TODO: Handle this case.
        case MqttPacketType.pubrel:
        // TODO: Handle this case.
        case MqttPacketType.pubcomp:
        // TODO: Handle this case.
        case MqttPacketType.suback:
        // TODO: Handle this case.
        case MqttPacketType.unsuback:
        // TODO: Handle this case.
        case MqttPacketType.pingresp:
          _eventController.add(PingRespReceived());
          _pingRespReceived = true;
        case MqttPacketType.disconnect:
          return false;
        // TODO: Handle this case.
        case MqttPacketType.auth:
        // TODO: Handle this case.
        default:
        // TODO: Handle this case.
      }
    }
    await networkConnection.transmit(_txDisconnectPacket!.toBytes());
    return false;
  }

  Future<void> publishQos0(TxPublishPacket pubPkt,
      {bool waitForConnection = false}) async {
    final txPkt =
        InternalTxPublishPacket(null, MqttQos.atMostOnce, pubPkt, this);
    if (waitForConnection && _activeConnectionState == null) {
      await connectionStatusStream.firstWhere((element) => element == true);
    }
    await networkConnection.transmit(txPkt.bytes);
  }

  final Map<String, int> _txTopicAliasMap = {};

  @override
  int createTopicAlias(String topic) {
    int maxAliasNo = _txTopicAliasMap.values.fold(
        1,
        (previousValue, element) =>
            (element > previousValue) ? element : previousValue);
    _txTopicAliasMap[topic] = maxAliasNo + 1;
    return maxAliasNo + 1;
  }

  @override
  int? getTopicAliasMapping(String topic) {
    return _txTopicAliasMap[topic];
  }

  void disconnect(
      {DisconnectPacket disconnectPkt =
          const DisconnectPacket(DisconnectReasonCode.normal)}) {
    _txDisconnectPacket = disconnectPkt;
    _disconnectFlag = true;
    _disconnectFlagStream.add(true);
  }

  Future<void> _dispose() async {
    _activeConnectionState?.dispose();
    await _eventController.close();
    await _connectionStatusController.close();
    await _disconnectFlagStream.close();
  }
}
