import 'dart:async';
import 'package:async/async.dart';
import 'package:cutie_mqtt/cutie_mqtt.dart';
import 'package:cutie_mqtt/src/conn_ack_packet.dart';
import 'package:cutie_mqtt/src/connect_packet.dart';
import 'package:cutie_mqtt/src/mqtt_fixed_header.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';
import 'package:cutie_mqtt/src/publish_packet.dart';
import 'package:cutie_mqtt/src/resettable_periodic_timer.dart';

import 'mqtt_events.dart';
import 'mqtt_network_connections.dart';

class MqttActiveConnectionState {
  final ResettablePeriodicTimer pingTimer;
  final StreamQueue<int> streamQ;

  MqttActiveConnectionState(this.pingTimer, this.streamQ);

  void dispose() {
    pingTimer.stop(dispose: true);
  }
}

class CutieMqttClient implements TopicAliasManager {
  final MqttNetworkConnection networkConnection;
  late String clientId;
  final StreamController<MqttEvent> _eventController =
  StreamController<MqttEvent>();

  final StreamController<bool> _connectionStatusController = StreamController<
      bool>.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  MqttActiveConnectionState? _activeConnectionState;

  bool get isConnected => _activeConnectionState != null;

  bool _disconnectFlag = false;
  final StreamController<bool> _disconnectFlagStream =
  StreamController<bool>.broadcast();

  CutieMqttClient(this.networkConnection, {String? initClientId}) {
    clientId =
        initClientId ?? "cutie_mqtt_${DateTime
            .now()
            .millisecondsSinceEpoch}";
  }

  Stream<MqttEvent> begin(ConnectPacket connPkt) {
    _eventController.onListen = () => _internalLoop(connPkt);
    // TODO: onCancel
    return _eventController.stream;
  }

  Future<(bool exit, StreamQueue<int>? streamQ)> _connect(
      ConnectPacket connPkt) async {
    final byteStream = await networkConnection.connect();
    if (byteStream == null) {
      _eventController.add(SocketConnectionFailure());
      return (false, null);
    }
    // byteStream.listen((event) => print("socket data: $event"),
    //     onDone: () => print("stream finished"));
    networkConnection.transmit(connPkt.toBytes(clientId));

    final streamQ = StreamQueue<int>(byteStream);
    final connackFixedHdr = await streamQ.take(2);

    // handle case where the stream ends before 2 bytes
    if (connackFixedHdr.length != 2) {
      _eventController.add(SocketEnded());
      return (false, null);
    }

    final fixedHdr = MqttFixedHeader.fromBytes(connackFixedHdr);
    if (fixedHdr!.data.packetType != MqttPacketType.connack) {
      _eventController
          .add(MalformedPacket(connackFixedHdr, message: "expected CONNACK"));
      return (true, null);
    }
    final remLen = fixedHdr.data.remainingLength;

    final connackBytes = await streamQ.take(remLen);
    if (connackBytes.length != remLen) {
      _eventController.add(SocketEnded());
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

  void _internalLoop(ConnectPacket connPkt) async {
    while (true) {
      final (exit, streamQ) = await _connect(connPkt);

      if (streamQ == null) {
        if (exit) {
          // connection failed but we shouldn't retry
          break;
        } else {
          if (_disconnectFlag) break;
          await Future.any([
            Future.delayed(Duration(seconds: connPkt.keepAliveSeconds)),
            _disconnectFlagStream.stream.first
          ]);
          if (_disconnectFlag) break;
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
      _connectionStatusController.add(true);
      final reconnect = await _useActiveNetworkConnection();
      _connectionStatusController.add(false);
      _activeConnectionState!.dispose();
      _activeConnectionState = null;

      if (!reconnect) break;
      connPkt.cleanStart = false;
    }
  }

  void _sendPingReq() {
    networkConnection
        .transmit(MqttFixedHeader(MqttPacketType.pingreq, 0, 0).toBytes());
  }

  //returns whether to reconnect or not
  Future<bool> _useActiveNetworkConnection() async {
    assert(_activeConnectionState != null);
    while (true) {
      final fixedHeaderBytes = await _activeConnectionState!.streamQ.take(2);
      // connection closed
      if (fixedHeaderBytes.length != 2) {
        return false;
      }
      final fixedHeaderParse = MqttFixedHeader.fromBytes(fixedHeaderBytes);
      if (fixedHeaderParse == null) {
        return true;
      }
      final packetBytes = await _activeConnectionState!.streamQ
          .take(fixedHeaderParse.data.remainingLength);
      if (packetBytes.length != fixedHeaderParse.data.remainingLength) {
        return false;
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
        // TODO: Handle this case.
        case MqttPacketType.disconnect:
        // TODO: Handle this case.
        case MqttPacketType.auth:
        // TODO: Handle this case.
        default:
        // TODO: Handle this case.
      }
    }
  }

  Future<void> publishQos0(TxPublishPacket pubPkt,
      {bool waitForConnection = false}) async {
    final txPkt =
    InternalTxPublishPacket(null, MqttQos.atMostOnce, pubPkt, this);
    if (waitForConnection && _activeConnectionState == null) {
      await connectionStatusStream.firstWhere((element) => element==true);
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
}
