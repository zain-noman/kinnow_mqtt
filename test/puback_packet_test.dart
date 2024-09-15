import 'package:cutie_mqtt/src/packets/puback_packet.dart';
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
    },
  );
}
