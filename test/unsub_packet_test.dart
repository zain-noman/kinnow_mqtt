import 'package:cutie_mqtt/src/packets/unsubscribe_packet.dart';
import 'package:test/test.dart';

void main() {
  test(
    "MqttPacketType.subscribe packet",
        () {
      final actual = InternalUnsubscribePacket(0xBEEF,
          UnsubscribePacket(["ninja", "digger", "snickers", "bigger"]))
          .toBytes();
      final expected = [
        0xA2,
        36,
        0xBE,
        0xEF,
        0,
        0, 5, ..."ninja".codeUnits,
        0, 6, ..."digger".codeUnits,
        0, 8, ..."snickers".codeUnits,
        0,6,..."bigger".codeUnits
      ];
      expect(actual,expected);
    },
  );
}
