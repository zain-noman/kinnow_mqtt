import 'package:cutie_mqtt/src/mqtt_fixed_header.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';
import 'package:test/test.dart';

void main() {
  group(
    "fixed header",
    () {
      test(
        "t1",
        () {
          final t = MqttFixedHeader.fromBytes([0x00]);
          expect(t, isNull);
        },
      );
      test(
        "t2",
        () {
          final t = MqttFixedHeader.fromBytes([0x15, 11]);
          expect(t, isNotNull);
          expect(t!.data.packetType, MqttPacketType.connect);
          expect(t.data.flags, 0x05);
          expect(t.data.remainingLength, 11);
          expect(t.nextBlockStart, isEmpty);
          expect(t.bytesConsumed, 2);
        },
      );
      test(
        "t2",
        () {
          final t = MqttFixedHeader(MqttPacketType.publish, 0x05, 5);
          expect(t.toBytes(), [0x35, 5]);
        },
      );
    },
  );
}
