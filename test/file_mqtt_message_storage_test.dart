import 'dart:io';

import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:test/test.dart';

void main() {
  group(
    "file mqtt storage",
    () {
      setUp(
        () async {
          final dir = Directory('./test/storage_dir');
          if (await dir.exists()) {
            await dir.delete(recursive: true);
          }
          await dir.create();
        },
      );

      test(
        "file mqtt storage",
        () async {
          final store = FileMqttMessageStorage('./test/storage_dir');
          await store.initialize("obra_dinn");

          expect(await store.fetchAll().toList(), isEmpty);

          final id1 = await store.storeMessage(MqttQos.exactlyOnce,
              TxPublishPacket(true, "topic1", StringOrBytes.fromString("1")));
          final id2 = await store.storeMessage(MqttQos.exactlyOnce,
              TxPublishPacket(true, "topic2", StringOrBytes.fromString("2")));
          expect(id1, isNot(id2));

          final l1 = await store.fetchAll().toList();

          expect(l1.length, 2);

          expect(l1[0].storageId, id1);
          expect(l1[0].packet.topic, 'topic1');

          expect(l1[1].storageId, id2);
          expect(l1[1].packet.topic, 'topic2');

          await store.remove(id1!);

          await store.dispose();

          final store2 = FileMqttMessageStorage('./test/storage_dir');
          await store2.initialize('obra_dinn');
          final l2 = await store2.fetchAll().toList();

          expect(l2[0].storageId, id2);
          expect(l2[0].packet.topic, 'topic2');
        },
      );
    },
  );
}
