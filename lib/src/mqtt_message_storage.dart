import 'dart:async';

import 'package:cutie_mqtt/cutie_mqtt.dart';
import 'package:cutie_mqtt/src/isar/tx_publish_pkt_isar.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';
import 'package:isar/isar.dart';

// how message storage can be implemented varies greatly with platform
abstract class MqttMessageStorage {
  Future<void> initialize(String clientId);

  Future<int?> storeMessage(MqttQos qos, TxPublishPacket publishPkt);

  Future<List<(TxPublishPacket, MqttQos, int)>> fetchAll();

  Future<void> remove(int id);

  Future<void> dispose();
}

// currently only supporting non web platforms so ill use isar
class IsarMqttMessageStorage extends MqttMessageStorage {
  final bool Function(MqttQos qos, TxPublishPacket pkt) filterFunc;
  final String databaseDir;
  Isar? isar;

  IsarMqttMessageStorage(this.filterFunc, this.databaseDir);

  @override
  Future<void> initialize(String clientId) async {
    isar = await Isar.open([TxPublishPktIsarSchema],
        directory: databaseDir, name: clientId);
  }

  @override
  Future<List<(TxPublishPacket, MqttQos, int)>> fetchAll() async {
    final isarPkts =
        await isar!.txPublishPktIsars.where(sort: Sort.asc).findAll();
    return isarPkts.map((e) => (e.toPkt(), e.qos, e.id)).toList();
  }

  @override
  Future<void> remove(int id) async {
    await isar!.writeTxn(() => isar!.txPublishPktIsars.delete(id));
  }

  @override
  Future<int?> storeMessage(MqttQos qos, TxPublishPacket publishPkt) async {
    bool store = filterFunc(qos, publishPkt);
    if (!store) return null;
    final isarPkt = TxPublishPktIsar.fromPacket(publishPkt, qos);

    int id = await isar!.writeTxn(
      () => isar!.txPublishPktIsars.put(isarPkt),
    );
    return id;
  }

  @override
  Future<void> dispose() async {
    await isar?.close();
  }
}
