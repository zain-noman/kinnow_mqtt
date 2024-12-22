import 'dart:async';
import 'mqtt_qos.dart';
import 'packets/publish_packet.dart';

class MqttMessageStorageRow {
  TxPublishPacket packet;
  MqttQos Qos;
  int storageId;

  MqttMessageStorageRow(this.packet, this.Qos, this.storageId);
}

// how message storage can be implemented varies greatly with platform
abstract class MqttMessageStorage {
  Future<void> initialize(String clientId);

  Future<int> storeMessage(MqttQos qos, TxPublishPacket publishPkt);

  Stream<MqttMessageStorageRow> fetchAll();

  Future<void> remove(int id);

  Future<void> dispose();
}
