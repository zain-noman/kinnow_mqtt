import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:kinnow_mqtt/src/packets/publish_packet.dart';

import 'package:test/test.dart';

class TestAliasMgr implements TopicAliasManager {
  int aliasId = 0;
  final Map<String, int> topicsMap = {};
  final Map<int, String> rxTopicAliasMap = {};

  @override
  int createTxTopicAlias(String topic) {
    aliasId++;
    return aliasId;
  }

  @override
  int? getTxTopicAlias(String topic) {
    return topicsMap[topic];
  }

  @override
  void createRxTopicAlias(String topic, int alias) {
    rxTopicAliasMap[alias] = topic;
  }

  @override
  String? getTopicForRxAlias(int alias) {
    return rxTopicAliasMap[alias];
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
      test(
        "internal Rx publish packet",
        () {
          final aliasMgr = TestAliasMgr();
          aliasMgr.rxTopicAliasMap[1] = "yasuo";
          final (rxPubPkt, aliasIssue) = RxPublishPacket.fromBytes(
            [
              0, 0, //no topic name
              0xBE, 0xEF, //packetId
              3, //prop len
              0x23, 00, 01, //topic alias 1
              ..."symphony dolphin".codeUnits
            ],
            0x0d,
            aliasMgr,
          );
          expect(rxPubPkt, isNotNull);
          expect(aliasIssue, false);
          expect(rxPubPkt?.retain, true);
          expect(rxPubPkt?.topic, "yasuo");
          expect(rxPubPkt?.payload.asString, "symphony dolphin");
          expect(rxPubPkt?.qos, MqttQos.exactlyOnce);
          expect(rxPubPkt?.payloadFormat, null);
          expect(rxPubPkt?.messageExpiryInterval, null);
          expect(rxPubPkt?.aliasUsed, true);
          expect(rxPubPkt?.responseTopic, null);
          expect(rxPubPkt?.correlationData, null);
          expect(rxPubPkt?.userProperties, isEmpty);
          expect(rxPubPkt?.contentType, null);
          expect(rxPubPkt?.subscriptionId, null);
          expect(rxPubPkt?.isDuplicate, true);
          expect(rxPubPkt?.packetId, 0xBEEF);
        },
      );
    },
  );
}
