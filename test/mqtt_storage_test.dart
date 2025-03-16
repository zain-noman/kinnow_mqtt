import 'dart:async';
import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:kinnow_mqtt/src/mqtt_fixed_header.dart';
import 'package:kinnow_mqtt/src/mqtt_packet_types.dart';
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

class MockStorage implements MqttMessageStorage {
  @override
  bool Function(MqttQos qos, TxPublishPacket publishPkt)? shouldStoreMessage;

  @override
  Future<void> dispose() async {}

  @override
  Stream<MqttMessageStorageRow> fetchAll() {
    return Stream.fromIterable([
      MqttMessageStorageRow(
        TxPublishPacket(
            false, "niceTryDiddy", StringOrBytes.fromString("Party")),
        MqttQos.atMostOnce,
        0,
      ),
      MqttMessageStorageRow(
        TxPublishPacket(
            false, "OIIAI", StringOrBytes.fromString("O II II A I")),
        MqttQos.atLeastOnce,
        1,
      ),
      MqttMessageStorageRow(
        TxPublishPacket(
            false, "Skibidi", StringOrBytes.fromString("gyat rizz")),
        MqttQos.exactlyOnce,
        2,
      )
    ]);
  }

  @override
  Future<void> initialize(String clientId) async {}

  @override
  Future<void> remove(int id) async {
    print("$id was removed");
  }

  @override
  Future<int?> storeMessage(MqttQos qos, TxPublishPacket publishPkt) async {
    print("${publishPkt.topic} was stored");
    return null;
  }
}

void main() {
  group("storage", () {
    test("stored messages are sent", () async {
      final net = TestNetworkConnection();
      List<MqttPacketType> packetsSentToBroker = [];
      net.packetReceivedControlller.stream.listen(
        (event) => packetsSentToBroker.add(event),
      );

      MockStorage storage = MockStorage();

      final c = KinnowMqttClient(net, storage: storage);
      final eventStream = c.begin(ConnectPacket(
          cleanStart: false,
          lastWill: null,
          keepAliveSeconds: 100,
          username: null,
          password: null));

      final eventsList = <MqttEvent>[];
      eventStream.listen(
        (event) => eventsList.add(event),
      );
      await Future.delayed(const Duration(seconds: 1));
      // send conn ack
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
      await Future.delayed(const Duration(seconds: 1));
      print(packetsSentToBroker);
      print(eventsList);
      expect(eventsList, contains(isA<StoredMessageSentQos0>()));

      // acknowledge QOS 1 and 2 pkts
      for (final i in PubackPacket(1, null, null, {}).toBytes()) {
        net.controller?.add(i);
      }
      for (final i in PubrecPacket(2, null, null, {}).toBytes()) {
        net.controller?.add(i);
      }
      await Future.delayed(const Duration(seconds: 1));
      expect(eventsList, contains(isA<StoredMessageSentQos1>()));
      for (final i in PubcompPacket(2, null, null, {}).toBytes()) {
        net.controller?.add(i);
      }
      await Future.delayed(const Duration(seconds: 1));
      expect(eventsList, contains(isA<StoredMessageSentQos2>()));
    });
  });
}
