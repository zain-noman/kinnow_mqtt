import 'dart:async';

import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:kinnow_mqtt/src/mqtt_fixed_header.dart';
import 'package:kinnow_mqtt/src/mqtt_packet_types.dart';
import 'package:kinnow_mqtt/src/packets/publish_packet.dart';
import 'package:test/test.dart';

class TestNetworkConnection implements MqttNetworkConnection {
  StreamController<int>? controller;
  final StreamController<MqttPacketType> packetReceivedControlller =
      StreamController<MqttPacketType>.broadcast();

  @override
  Future<Stream<int>?> connect() async {
    controller = StreamController<int>();
    return controller!.stream;
  }

  @override
  Future<bool> transmit(Iterable<int> bytes) async {
    final parseRes = MqttFixedHeader.fromBytes(bytes);
    if (parseRes?.data.packetType != null) {
      packetReceivedControlller.add(parseRes!.data.packetType);
    }
    return true;
  }

  @override
  Future<void> close() async {
    print("Mock Socket Closed");
  }
}

class MockAliasMgr implements TopicAliasManager {
  @override
  void createRxTopicAlias(String topic, int alias) {
    // TODO: implement createRxTopicAlias
  }

  @override
  int createTxTopicAlias(String topic) {
    // TODO: implement createTxTopicAlias
    throw UnimplementedError();
  }

  @override
  String? getTopicForRxAlias(int alias) {
    // TODO: implement getTopicForRxAlias
    throw UnimplementedError();
  }

  @override
  int? getTxTopicAlias(String topic) {
    // TODO: implement getTxTopicAlias
    throw UnimplementedError();
  }
}

void main() {
  group(
    "Malformed Packet Test",
    () {
      test(
        "connection lifecycle with malformed packet",
        () async {
          final net = TestNetworkConnection();
          net.packetReceivedControlller.stream.listen(
            (event) {
              print("Pkt recvd: ${event.name}");
              if (event != MqttPacketType.pingreq) return;
              print("ping request received by server");
              for (final i
                  in MqttFixedHeader(MqttPacketType.pingresp, 0, 0).toBytes()) {
                net.controller?.add(i);
              }
            },
          );

          final c = KinnowMqttClient(net);
          final eventStream = c.begin(ConnectPacket(
              cleanStart: false,
              lastWill: null,
              keepAliveSeconds: 5,
              username: null,
              password: null));
          final eventsList = <MqttEvent>[];
          eventStream.listen(
            (event) => eventsList.add(event),
          );
          await Future.delayed(const Duration(seconds: 1));
          for (final i in [
            0x20,
            0x09,
            0x00,
            0x00,
            0x06,
            0x21,
            0x00,
            0x0a,
            0x22,
            0x00,
            0x05
          ]) {
            net.controller?.add(i);
          }
          await Future.delayed(const Duration(seconds: 7));
          expect(
              eventsList,
              containsAllInOrder([
                isA<ConnAckEvent>(),
                isA<PingReqSent>(),
                isA<PingRespReceived>()
              ]));

          MockAliasMgr mockAliasMgr = MockAliasMgr();
          final qos0Msg = InternalTxPublishPacket(
            null,
            MqttQos.atMostOnce,
            TxPublishPacket(
              false,
              "monke",
              StringOrBytes.fromString("abundalakaka"),
            ),
            mockAliasMgr,
          );
          final malformedBytes = qos0Msg.bytes;
          malformedBytes[0] =
              malformedBytes[0] | 0x06; //set qos to 3 (malformed)

          final disconnectEventFut =
              net.packetReceivedControlller.stream.firstWhere(
            (element) => element == MqttPacketType.disconnect,
          );

          for (final i in malformedBytes) {
            net.controller?.add(i);
          }

          await disconnectEventFut;

          await Future.delayed(const Duration(seconds: 1));

          expect(
              eventsList,
              containsAllInOrder([
                isA<ConnAckEvent>(),
                isA<PingReqSent>(),
                isA<PingRespReceived>(),
                isA<MalformedPacket>(),
                isA<ShutDown>(),
              ]));
        },
      );
    },
  );
}
