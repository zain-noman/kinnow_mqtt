import 'dart:async';
import 'package:async/async.dart';
import 'packets/unsubscribe_packet.dart';
import 'packets/unsuback_packet.dart';
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
  final unsubAckController = StreamController<UnsubackPacket>.broadcast();

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

/// The main Mqtt Client class
class KinnowMqttClient {
  /// the duration between reconnection attempts
  Duration reconnectDelay;

  /// The underlying network connection
  ///
  /// Can be a [TcpMqttNetworkConnection] or a [SslTcpMqttNetworkConnection] or
  /// websocket or any class that implements [MqttNetworkConnection].
  final MqttNetworkConnection networkConnection;

  /// A unique identifier of the client.
  ///
  /// Please ensure using unique clientIds on different devices. If the same clientId
  /// is used, disconnections may occur.
  /// The [clientId] can be set in the constructor or at a later time before calling [begin].
  /// Any changes after [begin] will not take effect
  late String clientId;
  final StreamController<MqttEvent> _eventController =
      StreamController<MqttEvent>.broadcast();

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  final _operationQueue = MqttOperationQueue<MqttActiveConnectionState>();

  /// This stream provides information on whether the client is connected
  ///
  /// A 'true' value indicates that the client is connected and a 'false' indicates
  /// disconnection. This is a broadcast stream and can be listened to multiple times
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  MqttActiveConnectionState? _activeConnectionState;

  /// whether the client is currently connected
  bool get isConnected => _activeConnectionState != null;

  bool _disconnectFlag = false;
  final StreamController<bool> _disconnectFlagStream =
      StreamController<bool>.broadcast();
  DisconnectPacket? _txDisconnectPacket;

  final _rxPacketController = StreamController<RxPublishPacket>.broadcast();

  /// This stream provides the publish packets sent by the server
  ///
  /// This is a broadcast stream and can be listened to multiple times
  Stream<RxPublishPacket> get receivedMessagesStream =>
      _rxPacketController.stream;

  /// Create a new Mqtt Client
  ///
  /// [networkConnection] : The underlying tcp/tls/websocket connection. see [MqttNetworkConnection]
  /// [initClientId] : The client Id to use, if not specified a client id is generated based on current time.
  /// The [clientId] can also be set at a later time before calling [begin]. Any changes after [begin] will not take effect
  KinnowMqttClient(this.networkConnection,
      {String? initClientId,
      this.reconnectDelay = const Duration(seconds: 10)}) {
    clientId =
        initClientId ?? "kinnow_mqtt_${DateTime.now().millisecondsSinceEpoch}";
    _disconnectFlagStream.onListen = () {
      if (_disconnectFlag == true) {
        _disconnectFlagStream.add(true);
      }
    };
  }

  bool _begun = false;

  /// Start the mqtt connection. return the stream of events. This should not be called twice
  Stream<MqttEvent> begin(ConnectPacket connPkt) {
    if (_begun) {
      throw StateError("Client is already started");
    }
    _begun = true;
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
            Future.delayed(reconnectDelay),
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
          if (suback != null) {
            _activeConnectionState!.subAckController.add(suback);
          }
        // TODO: malformed packet
        case MqttPacketType.unsuback:
          final unsuback = UnsubackPacket.fromBytes(packetBytes);
          if (unsuback != null) {
            _activeConnectionState!.unsubAckController.add(unsuback);
          }
        // TODO: malformed packet
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

  /// Publish a Message with QoS 0.
  ///
  /// This function will wait until there is a
  /// network connection and then send the message. QoS 0 messages are not acknowledged
  /// by the server so these is a slight chance that QoS 0 messages are not received.
  /// returns a future that completes with 'true' if the message was transmitted and
  /// completes with false if the client shuts down before the message could be sent
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

  int _generatePacketId() {
    _packetIdGenerator++;
    return _packetIdGenerator;
  }

  /// Publish a Message with QoS 1.
  ///
  /// QoS 1 messages are acknowledged
  /// by the server so QoS 1 messages are received at least once but may be received
  /// more than once. Returns a future that completes with the [PubackPacket] sent
  /// by the server if the message was transmitted and completes with null if the
  /// client shuts down before the message could be sent
  Future<PubackPacket?> publishQos1(TxPublishPacket pubPkt) async {
    bool isDuplicate = false;
    final token = _operationQueue.generateToken();
    final packetId = _generatePacketId();
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

  /// Publish a Message with QoS 2.
  ///
  /// QoS 2 messages are received exactly once but have
  /// more overhead. returns a future that completes with the [PubrecPacket] and
  /// the [PubcompPacket] sent by the server if the message was transmitted and
  /// completes with null if the client shuts down before the message could be sent
  Future<(PubrecPacket, PubcompPacket)?> publishQos2(
      TxPublishPacket pubPkt) async {
    bool isDuplicate = false;
    final token = _operationQueue.generateToken();
    final packetId = _generatePacketId();

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

  /// Subscribe to a topic.
  ///
  /// Returns a Future that completes with a [SubackPacket] if the subscription
  /// is successful and null if the client shuts down before subscription completes.
  /// After subscription messages can be received on [receivedMessagesStream]
  Future<SubackPacket?> subscribe(SubscribePacket subPkt) async {
    final token = _operationQueue.generateToken();
    final packetId = _generatePacketId();
    final pktBytes = InternalSubscribePacket(packetId, subPkt).toBytes();
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

  /// Unsubscribe from a topic.
  ///
  /// Returns a Future that completes with a [UnsubackPacket] if the subscription
  /// is successful and null if the client shuts down before the unsubscribe completes
  Future<UnsubackPacket?> unsubscribe(UnsubscribePacket unSubPkt) async {
    final token = _operationQueue.generateToken();
    final packetId = _generatePacketId();
    final pktBytes = InternalUnsubscribePacket(packetId, unSubPkt).toBytes();
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

      final unsubAck = await _activeConnectionState!.unsubAckController.stream
          .cast<UnsubackPacket?>()
          .firstWhere((element) => element?.packetId == packetId,
              orElse: () => null)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (unsubAck != null) return unsubAck;
    }
  }

  /// Disconnect from the server
  ///
  /// If the client is not connected when [disconnect] is called, the client
  /// will disconnect without sending the [disconnectPkt].
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
