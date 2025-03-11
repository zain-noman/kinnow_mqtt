import 'dart:async';

import 'mqtt_qos.dart';
import 'packets/publish_packet.dart';

class MqttMessageStorageRow {
  TxPublishPacket packet;
  MqttQos qos;
  int storageId;

  MqttMessageStorageRow(this.packet, this.qos, this.storageId);
}

// how message storage can be implemented varies greatly with platform
abstract class MqttMessageStorage {
  /// initializes the Storage
  ///
  /// this is called internally at when the [KinnowMqttClient] begins.
  /// [clientId] should be used to differentiate the messages stored for one user
  /// vs another user
  Future<void> initialize(String clientId);

  /// Store a message and return a storageId
  Future<int?> storeMessage(MqttQos qos, TxPublishPacket publishPkt);

  /// return a stream of all stored messages
  Stream<MqttMessageStorageRow> fetchAll();

  /// remove a stored message with a given storageId
  Future<void> remove(int id);

  /// dispose
  Future<void> dispose();

  /// this can be used by a user to specify which messages to store
  ///
  /// if null all messages will be stored
  bool Function(MqttQos qos, TxPublishPacket publishPkt)? shouldStoreMessage;
}
