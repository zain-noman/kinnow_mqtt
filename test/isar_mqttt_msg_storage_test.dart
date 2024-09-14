import 'dart:ffi';

import 'package:cutie_mqtt/cutie_mqtt.dart';
import 'package:cutie_mqtt/src/isar/tx_publish_pkt_isar.dart';
import 'package:cutie_mqtt/src/mqtt_message_storage.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path_lib;

void main() {
  group(
    "Isar Mqtt Message Storage",
    () {
      String rootPathAbs = "";
      setUpAll(
        () async {
          rootPathAbs = (path_lib.context.dirname(path_lib.current) == "test")
              ? path_lib.context
                  .normalize(path_lib.context.absolute(path_lib.current, ".."))
              : path_lib.context.absolute(path_lib.current);
          await Isar.initializeIsarCore(libraries: {
            Abi.linuxX64:
                path_lib.context.join(rootPathAbs, "libisar_linux_x64.so")
          });
          print("Isar Core initialized");
        },
      );
      test(
        "basic working",
        () async {
          final storage = IsarMqttMessageStorage((qos, pkt) => true,
              path_lib.context.join(rootPathAbs, "test", "testDbs"));
          await storage.initialize("mrWhite");
          await storage.isar!
              .writeTxn(() => storage.isar!.txPublishPktIsars.clear());

          final initialData = await storage.fetchAll();
          expect(initialData, isEmpty);

          final id1 = await storage.storeMessage(
              MqttQos.atMostOnce,
              TxPublishPacket(
                  false, "monke", StringOrBytes.fromString("rizz")));
          expect(id1, isNotNull);
          final id2 = await storage.storeMessage(
              MqttQos.atMostOnce,
              TxPublishPacket(
                  false, "monke", StringOrBytes.fromString("rizz")));
          expect(id2, isNotNull);
          expect(id2 != id1, true);

          final data2 = await storage.fetchAll();
          expect(data2.length, 2);
          expect(data2[0].$3, id1);
          expect(data2[1].$3, id2);

          await storage.remove(id1!);
          final data3 = await storage.fetchAll();
          expect(data3.length, 1);
          expect(data3[0].$3, id2);

          await storage.remove(id2!);
          final data4 = await storage.fetchAll();
          expect(data4, isEmpty);

          await storage.dispose();
        },
      );
      test("filtering functionality working", () async {
        final storage = IsarMqttMessageStorage(
          // only store QoS1 and QoS2 messages
          (qos, pkt) => qos != MqttQos.atMostOnce,
          path_lib.context.join(rootPathAbs, "test", "testDbs"),
        );
        await storage.initialize("pinkman");
        await storage.isar!
            .writeTxn(() => storage.isar!.txPublishPktIsars.clear());

        final initialData = await storage.fetchAll();
        expect(initialData, isEmpty);

        final id1 = await storage.storeMessage(MqttQos.atMostOnce,
            TxPublishPacket(false, "monke", StringOrBytes.fromString("rizz")));
        expect(id1, isNull);
        expect(await storage.fetchAll(), isEmpty);

        final id2 = await storage.storeMessage(MqttQos.atLeastOnce,
            TxPublishPacket(false, "monke", StringOrBytes.fromString("rizz")));
        expect(id2, isNotNull);
        expect((await storage.fetchAll()).length, 1);
        await storage.dispose();
      });
    },
  );
}
