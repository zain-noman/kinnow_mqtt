import 'package:cutie_mqtt/src/disconnect_packet.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test(
    "toBytes",
    () {
      expect(DisconnectPacket(DisconnectReasonCode.normal).toBytes(),
          [0xE0, 2, 0x00, 0x00]);
      expect(
          DisconnectPacket(DisconnectReasonCode.normal, reasonString: "skibidi")
              .toBytes(),
          [
            0xE0, 12, //fixed hdr
            0x00, //reason code
            10, //props len
            0x1F, //reason string property id
            0, 7, ..."skibidi".codeUnits
          ]);
    },
  );
  test(
    "fromBytes",
    () {
      {
        final t = DisconnectPacket.fromBytes([0x00, 0x00]);
        expect(t, isNotNull);
        expect(t!.reasonCode, DisconnectReasonCode.normal);
        expect(t.serverReference, isNull);
        expect(t.reasonString, isNull);
        expect(t.sessionExpiryInterval, isNull);
        expect(t.userProperties, isEmpty);
      }
      {
        final t = DisconnectPacket.fromBytes([
          0x00, //reason code
          10, //props len
          0x1F, //reason string property id
          0, 7, ..."skibidi".codeUnits
        ]);
        expect(t, isNotNull);
        expect(t!.reasonCode, DisconnectReasonCode.normal);
        expect(t.serverReference, isNull);
        expect(t.reasonString, "skibidi");
        expect(t.sessionExpiryInterval, isNull);
        expect(t.userProperties, isEmpty);
      }
    },
  );
}
