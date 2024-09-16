import 'package:cutie_mqtt/src/packets/unsuback_packet.dart';
import 'package:test/test.dart';

void main() {
  test(
    "unsuback packte",
        () {
      final unsub = UnsubackPacket.fromBytes([0xBE, 0xEF, 0, 0x00, 0x11, 0x91]);
      expect(unsub, isNotNull);
      expect(unsub?.packetId, 0xBEEF);
      expect(unsub?.reasonCodes, [
        UnsubackReasonCode.success,
        UnsubackReasonCode.noSubscriptionExisted,
        UnsubackReasonCode.packetIdentifierInUse
      ]);
    },
  );
}
