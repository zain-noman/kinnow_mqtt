import 'package:kinnow_mqtt/src/packets/pub_misc_packet.dart';

import 'package:test/test.dart';

void main() {
  group(
    "puback tests",
    () {
      test(
        "just packetId",
        () {
          final pkt = PubackPacket.fromBytes([0x01, 0x01]);
          expect(pkt, isNotNull);
          expect(pkt?.packetId, 257);
          expect(pkt?.reasonCode, null);
          expect(pkt?.reasonString, null);
          expect(pkt?.userProperties, isEmpty);
        },
      );
      test(
        " packetId and reason",
        () {
          final pkt = PubackPacket.fromBytes([0x01, 0x01, 0x00]);
          expect(pkt, isNotNull);
          expect(pkt?.packetId, 257);
          expect(pkt?.reasonCode, PubackReasonCode.success);
          expect(pkt?.reasonString, null);
          expect(pkt?.userProperties, isEmpty);
        },
      );
      test(
        " packetId, reason and reasonString",
        () {
          final pkt = PubackPacket.fromBytes(
              [0x01, 0x01, 0x00, 8, 0x1F, 0, 5, ..."hello".codeUnits]);
          expect(pkt, isNotNull);
          expect(pkt?.packetId, 257);
          expect(pkt?.reasonCode, PubackReasonCode.success);
          expect(pkt?.reasonString, "hello");
          expect(pkt?.userProperties, isEmpty);
        },
      );
      test(
        "puback to Bytes",
        () {
          expect(
              PubackPacket(5, PubackReasonCode.success, "bruh", {}).toBytes(), [
            0x40,
            11,
            00,
            05,
            00,
            7,
            0x1F,
            0,
            4,
            ..."bruh".codeUnits,
          ]);
        },
      );

      test(
        " packetId, reason and reasonString, but pubrec",
        () {
          final pkt = PubrecPacket.fromBytes(
              [0x01, 0x01, 0x00, 8, 0x1F, 0, 5, ..."hello".codeUnits]);
          expect(pkt, isNotNull);
          expect(pkt?.packetId, 257);
          expect(pkt?.reasonCode, PubackReasonCode.success);
          expect(pkt?.reasonString, "hello");
          expect(pkt?.userProperties, isEmpty);
        },
      );
      test(
        "puback to Bytes, but pubrec",
        () {
          expect(
              PubrecPacket(5, PubackReasonCode.success, "bruh", {}).toBytes(), [
            0x50,
            11,
            00,
            05,
            00,
            7,
            0x1F,
            0,
            4,
            ..."bruh".codeUnits,
          ]);
        },
      );

      test(
        " packetId, reason and reasonString, but pubcomp",
        () {
          final pkt = PubcompPacket.fromBytes(
              [0x01, 0x01, 0x00, 8, 0x1F, 0, 5, ..."hello".codeUnits]);
          expect(pkt, isNotNull);
          expect(pkt?.packetId, 257);
          expect(pkt?.reasonCode, PubcompReasonCode.success);
          expect(pkt?.reasonString, "hello");
          expect(pkt?.userProperties, isEmpty);
        },
      );
      test(
        "to Bytes, but pubcomp",
        () {
          expect(
              PubcompPacket(5, PubcompReasonCode.success, "bruh", {}).toBytes(),
              [
                0x70,
                11,
                00,
                05,
                00,
                7,
                0x1F,
                0,
                4,
                ..."bruh".codeUnits,
              ]);
        },
      );
    },
  );
}
