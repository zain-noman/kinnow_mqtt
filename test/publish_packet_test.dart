import 'package:cutie_mqtt/src/byte_utils.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';
import 'package:cutie_mqtt/src/packets/publish_packet.dart';
import 'package:test/test.dart';

class TestAliasMgr implements TopicAliasManager {
  int aliasId = 0;
  final Map<String, int> topicsMap = {};

  @override
  int createTopicAlias(String topic) {
    aliasId++;
    return aliasId;
  }

  @override
  int? getTopicAliasMapping(String topic) {
    return topicsMap[topic];
  }
}

void main() {
  group(
    "publish packet test",
    () {
      test(
        "internal tx",
        () {
          final aliasMgr = TestAliasMgr();
          final t = InternalTxPublishPacket(
              null,
              MqttQos.atMostOnce,
              TxPublishPacket(
                false,
                "test",
                StringOrBytes.fromString("testPayload"),
              ),
              aliasMgr);
          expect(t.bytes, [
            0x30,
            18,
            0,
            4,
            ..."test".codeUnits,
            0,
            ..."testPayload".codeUnits
          ]);
          t.isDuplicate = true;
          expect(t.bytes, [
            0x38,
            18,
            0,
            4,
            ..."test".codeUnits,
            0,
            ..."testPayload".codeUnits
          ]);
        },
      );
    },
  );
}
