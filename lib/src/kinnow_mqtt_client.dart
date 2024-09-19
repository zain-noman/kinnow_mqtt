import 'dart:async';
import 'package:async/async.dart';
import 'packets/conn_ack_packet.dart';
import 'packets/disconnect_packet.dart';
import 'mqtt_fixed_header.dart';
import 'mqtt_operation_queue.dart';
import 'mqtt_packet_types.dart';
import 'mqtt_qos.dart';
import 'packets/pub_misc_packet.dart';
import 'packets/publish_packet.dart';
import 'packets/suback_packet.dart';
import 'packets/subscribe_packet.dart';
import 'resettable_periodic_timer.dart';
import 'mqtt_network_connections.dart';
import 'mqtt_events.dart';
import 'packets/connect_packet.dart';

class MqttActiveConnectionState implements TopicAliasManager {
  final ResettablePeriodicTimer pingTimer;
  final StreamQueue<int> streamQ;
  final Completer<Null> pingRespTimeoutCompleter = Completer<Null>();

  final Map<String, int> _txTopicAliasMap = {};
  final Map<int, String> _rxTopicAliasMap = {};

  // receivedPacketStreams
  final pubAckController = StreamController<PubackPacket>.broadcast();
  final pubRecController = StreamController<PubrecPacket>.broadcast();
  final pubCompController = StreamController<PubcompPacket>.broadcast();
  final subAckController = StreamController<SubackPacket>.broadcast();

  MqttActiveConnectionState(this.pingTimer, this.streamQ);

  void dispose() {
    pingTimer.stop(dispose: true);
    pubAckController.close();
    pubRecController.close();
  }

  @override
  int createTxTopicAlias(String topic) {
    int maxAliasNo = _txTopicAliasMap.values.fold(
        1,
        (previousValue, element) =>
            (element > previousValue) ? element : previousValue);
    _txTopicAliasMap[topic] = maxAliasNo + 1;
    return maxAliasNo + 1;
  }

  @override
  int? getTxTopicAlias(String topic) {
    return _txTopicAliasMap[topic];
  }

  @override
  void createRxTopicAlias(String topic, int alias) {
    _rxTopicAliasMap[alias] = topic;
  }

  @override
  String? getTopicForRxAlias(int alias) {
    return _rxTopicAliasMap[alias];
  }
}

class KinnowMqttClient {
  final MqttNetworkConnection networkConnection;
  late String clientId;
  final StreamController<MqttEvent> _eventController =
      StreamController<MqttEvent>.broadcast();

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  final _operationQueue = MqttOperationQueue<MqttActiveConnectionState>();

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  MqttActiveConnectionState? _activeConnectionState;

  bool get isConnected => _activeConnectionState != null;

  bool _disconnectFlag = false;
  final StreamController<bool> _disconnectFlagStream =
      StreamController<bool>.broadcast();
  DisconnectPacket? _txDisconnectPacket;

  final _rxPacketController = StreamController<RxPublishPacket>.broadcast();

  Stream<RxPublishPacket> get receivedMessagesStream =>
      _rxPacketController.stream;

  KinnowMqttClient(this.networkConnection, {String? initClientId}) {
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
    // byteStream.listen((event) => print("socket data: $event"),
    //     onDone: () => print("stream finished"));
    networkConnection.transmit(connPkt.toBytes(clientId));

    final streamQ = StreamQueue<int>(byteStream);
    bool timedOut = false;
    final (connackFixedHdr, socketEnd, bytesTaken) =
        await MqttFixedHeader.fromStreamQueue(streamQ).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        timedOut = true;
        return (null, false, null);
      },
    );

    if (timedOut) {
      _eventController.add(ConnackTimedOut());
      return (false, null);
    }

    if (socketEnd) {
      _eventController.add(NetworkEnded());
      return (false, null);
    }

    if (connackFixedHdr == null) {
      _eventController
          .add(MalformedPacket(bytesTaken!, message: "expected CONNACK"));
      return (true, null);
    }

    if (connackFixedHdr.packetType != MqttPacketType.connack) {
      _eventController
          .add(MalformedPacket(bytesTaken!, message: "expected CONNACK"));
      return (true, null);
    }
    final remLen = connackFixedHdr.remainingLength;

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
      _operationQueue.start(_activeConnectionState!);
      _activeConnectionState!.pingTimer.start();
      _connectionStatusController.add(true);
      final reconnect = await _useActiveNetworkConnection();
      _connectionStatusController.add(false);
      _activeConnectionState!.dispose();
      _activeConnectionState = null;
      _operationQueue.pause();

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
          final (rxPub, aliasIssue) = RxPublishPacket.fromBytes(packetBytes,
              fixedHeaderParse.data.flags, _activeConnectionState!);
          if (rxPub == null) {
            // TODO: Handle malformed packet and alias issue
            break;
          }
          _handleRxPublishPkt(rxPub);
        case MqttPacketType.puback:
          final puback = PubackPacket.fromBytes(packetBytes);
          if (puback != null) {
            _activeConnectionState!.pubAckController.add(puback);
          }
        // TODO: malformed packet
        case MqttPacketType.pubrec:
          final pubrec = PubrecPacket.fromBytes(packetBytes);
          if (pubrec != null) {
            _activeConnectionState!.pubRecController.add(pubrec);
          }
        // TODO: malformed packet
        case MqttPacketType.pubrel:
          final pubRel = PubrelPacket.fromBytes(packetBytes);
          if (pubRel != null) {
            _handlePubrelPacket(pubRel);
          }
        // TODO: malformed packet
        case MqttPacketType.pubcomp:
          final pubcomp = PubcompPacket.fromBytes(packetBytes);
          if (pubcomp != null) {
            _activeConnectionState!.pubCompController.add(pubcomp);
          }
        // TODO: malformed packet
        case MqttPacketType.suback:
          final suback = SubackPacket.fromBytes(packetBytes);
          if (suback!= null){
            _activeConnectionState!.subAckController.add(suback);
          }
        // TODO: malformed packet
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

  Future<bool> publishQos0(TxPublishPacket pubPkt) {
    final token = _operationQueue.generateToken();
    return _operationQueue.addToQueueAndExecute(
      token,
      (state) async {
        final txPkt = InternalTxPublishPacket(
            null, MqttQos.atMostOnce, pubPkt, _activeConnectionState!);
        await networkConnection.transmit(txPkt.bytes);
      },
    ).then((value) => value == OperationResult.operationExecuted);
  }

  int _packetIdGenerator = 0;

  int generatePacketId() {
    _packetIdGenerator++;
    return _packetIdGenerator;
  }

  Future<PubackPacket?> publishQos1(TxPublishPacket pubPkt) async {
    bool isDuplicate = false;
    final token = _operationQueue.generateToken();
    final packetId = generatePacketId();
    while (true) {
      final sent = await _operationQueue.addToQueueAndExecute(
        token,
        (state) async {
          final internalPkt = InternalTxPublishPacket(
              packetId, MqttQos.atLeastOnce, pubPkt, state);
          if (isDuplicate) internalPkt.isDuplicate = true;
          await networkConnection.transmit(internalPkt.bytes);
        },
      );

      if (sent == OperationResult.operationCanceledByShutdown) return null;

      if (sent == OperationResult.operationCanceledByPause) continue;
      if (_activeConnectionState == null) continue;

      final pubAck = await _activeConnectionState!.pubAckController.stream
          .cast<PubackPacket?>()
          .firstWhere((element) => element?.packetId == packetId,
              orElse: () => null)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (pubAck != null) return pubAck;

      isDuplicate = true;
    }
  }

  Future<(PubrecPacket, PubcompPacket)?> publishQos2(
      TxPublishPacket pubPkt) async {
    bool isDuplicate = false;
    final token = _operationQueue.generateToken();
    final packetId = generatePacketId();

    PubrecPacket? pubRec;
    while (true) {
      final sent = await _operationQueue.addToQueueAndExecute(
        token,
        (state) async {
          final internalPkt = InternalTxPublishPacket(
              packetId, MqttQos.exactlyOnce, pubPkt, state);
          if (isDuplicate) internalPkt.isDuplicate = true;
          await networkConnection.transmit(internalPkt.bytes);
        },
      );

      if (sent == OperationResult.operationCanceledByShutdown) return null;

      if (sent == OperationResult.operationCanceledByPause) continue;
      if (_activeConnectionState == null) continue;

      pubRec = await _activeConnectionState!.pubRecController.stream
          .cast<PubrecPacket?>()
          .firstWhere((element) => element?.packetId == packetId,
              orElse: () => null)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (pubRec != null) break;

      isDuplicate = true;
    }

    PubcompPacket? pubComp;
    while (true) {
      final sent = await _operationQueue.addToQueueAndExecute(
        token,
        (state) async {
          await networkConnection
              .transmit(PubrelPacket(packetId, null, null, const {}).toBytes());
        },
      );

      if (sent == OperationResult.operationCanceledByShutdown) return null;

      if (sent == OperationResult.operationCanceledByPause) continue;
      if (_activeConnectionState == null) continue;

      pubComp = await _activeConnectionState!.pubCompController.stream
          .cast<PubcompPacket?>()
          .firstWhere((element) => element?.packetId == packetId,
              orElse: () => null)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (pubComp != null) break;

      isDuplicate = true;
    }
    return (pubRec, pubComp);
  }

  Future<SubackPacket?> subscribe(SubscribePacket sub_pkt) async {
    final token = _operationQueue.generateToken();
    final packetId = generatePacketId();
    final pktBytes = InternalSubscribePacket(packetId, sub_pkt).toBytes();
    while (true) {
      final sent = await _operationQueue.addToQueueAndExecute(
        token,
        (state) async {
          await networkConnection.transmit(pktBytes);
        },
      );

      if (sent == OperationResult.operationCanceledByShutdown) return null;

      if (sent == OperationResult.operationCanceledByPause) continue;
      if (_activeConnectionState == null) continue;

      final subAck = await _activeConnectionState!.subAckController.stream
          .cast<SubackPacket?>()
          .firstWhere((element) => element?.packetId == packetId,
              orElse: () => null)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (subAck != null) return subAck;
    }
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
    _operationQueue.dispose();
  }

  final _qos2MessagesAwaitingRelease = <int, RxPublishPacket>{};

  void _handleRxPublishPkt(RxPublishPacket rxPub) {
    switch (rxPub.qos) {
      case MqttQos.atMostOnce:
        _rxPacketController.add(rxPub);
      case MqttQos.atLeastOnce:
        if (rxPub.packetId == null) {
          _eventController.add(
              MalformedPacket(null, message: "qos1 received without packetId"));
          return;
        }
        final token = _operationQueue.generateToken();
        unawaited(_operationQueue.addToQueueAndExecute(
          token,
          (state) async {
            networkConnection.transmit(
                PubackPacket(rxPub.packetId!, null, null, const {}).toBytes());
          },
        ));
        _rxPacketController.add(rxPub);
      case MqttQos.exactlyOnce:
        if (rxPub.packetId == null) {
          _eventController.add(
              MalformedPacket(null, message: "qos1 received without packetId"));
          return;
        }
        _qos2MessagesAwaitingRelease[rxPub.packetId!] = rxPub;
    }
  }

  void _handlePubrelPacket(PubrelPacket pubRel) {
    final correspondingMessage = _qos2MessagesAwaitingRelease[pubRel.packetId];
    if (correspondingMessage != null) {
      final token = _operationQueue.generateToken();
      unawaited(_operationQueue.addToQueueAndExecute(
        token,
        (state) async {
          networkConnection.transmit(
              PubcompPacket(pubRel.packetId, null, null, const {}).toBytes());
        },
      ));
      _qos2MessagesAwaitingRelease.remove(pubRel.packetId);
      _rxPacketController.add(correspondingMessage);
    } else {
      final token = _operationQueue.generateToken();
      unawaited(_operationQueue.addToQueueAndExecute(
        token,
        (state) async {
          networkConnection.transmit(PubcompPacket(
              pubRel.packetId,
              PubcompReasonCode.packetIdentifierNotFound,
              null, const {}).toBytes());
        },
      ));
    }
  }
}
