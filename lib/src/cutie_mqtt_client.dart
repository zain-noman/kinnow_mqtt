import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:cutie_mqtt/src/conn_ack_packet.dart';
import 'package:cutie_mqtt/src/connect_packet.dart';
import 'package:cutie_mqtt/src/mqtt_fixed_header.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';
import 'package:cutie_mqtt/src/publish_packet.dart';

abstract class MqttNetworkConnection {
  Future<Stream<int>?> connect();

  void transmit(Iterable<int> bytes);
}

class TcpMqttNetworkConnection implements MqttNetworkConnection {
  final String host;
  final int port;
  Socket? currentSocket;

  @override
  Future<Stream<int>?> connect() async {
    try {
      final socket = await Socket.connect(host, port);
      // socket.setOption(SocketOption.tcpNoDelay,true);
      currentSocket = socket;
      return socket.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          for (final d in data) {
            sink.add(d);
          }
        },
      ));
    } catch (e) {
      return null;
    }
  }

  @override
  void transmit(Iterable<int> bytes) {
    currentSocket!.add(bytes.toList());
  }

  TcpMqttNetworkConnection(this.host, this.port);
}

class CutieMqttClient implements TopicAliasManager {
  final MqttNetworkConnection networkConnection;
  late String clientId;

  Future<ConnAckPacket?> connect(ConnectPacket connPkt) async {
    final byteStream = await networkConnection.connect();
    if (byteStream == null) return null;
    // byteStream.listen((event) => print("socket data: $event"),
    //     onDone: () => print("stream finished"));
    print("send connPkt");
    networkConnection.transmit(connPkt.toBytes(clientId));
    print("sent connPkt");

    final streamQ = StreamQueue<int>(byteStream);
    final connackFixedHdr = await streamQ.take(2);
    final fixedHdr = MqttFixedHeader.fromBytes(connackFixedHdr);
    if (fixedHdr!.data.packetType != MqttPacketType.connack) return null;
    final remLen = fixedHdr.data.remainingLength;
    final connackBytes = await streamQ.take(remLen);
    return ConnAckPacket.fromBytes(connackBytes);
    // return null;
  }

  CutieMqttClient(this.networkConnection, {String? initClientId}) {
    clientId =
        initClientId ?? "cutie_mqtt_${DateTime.now().millisecondsSinceEpoch}";
  }

  void publishQos0(TxPublishPacket pubPkt) {
    final txPkt =
        InternalTxPublishPacket(null, MqttQos.atMostOnce, pubPkt, this);
    networkConnection.transmit(txPkt.bytes);
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
