import 'package:kinnow_mqtt/kinnow_mqtt.dart';
import 'package:test/test.dart';

void main() {
  test(
    "suback",
    () {
      final suback = SubackPacket.fromBytes([0xBE, 0xEF, 0x00, 0x01, 0x02]);
      expect(suback, isNotNull);
      expect(suback?.reasonCodes,
          [SubackReasonCode.grantedQoS1, SubackReasonCode.grantedQoS2]);
      expect(suback?.packetId, 0xBEEF);
      expect(suback?.reasonString, null);
      expect(suback?.userProperties, isEmpty);
    },
  );
}
