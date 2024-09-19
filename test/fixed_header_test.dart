import 'package:async/async.dart';
import 'package:kinnow_mqtt/src/mqtt_fixed_header.dart';
import 'package:kinnow_mqtt/src/mqtt_packet_types.dart';
import 'package:test/test.dart';

void main() {
  group(
    "fixed header",
    () {
      test(
        "t1",
        () async {
          final q = StreamQueue(Stream.fromIterable([0x00]));
          final (t, streamEnded, _) = await MqttFixedHeader.fromStreamQueue(q);
          expect(t, isNull);
          expect(streamEnded, true);
        },
      );
      test(
        "t2",
        () async {
          final q = StreamQueue(Stream.fromIterable([0x15, 11]));
          final (t, streamEnded, _) = await MqttFixedHeader.fromStreamQueue(q);
          expect(t, isNotNull);
          expect(t!.packetType, MqttPacketType.connect);
          expect(t.flags, 0x05);
          expect(t.remainingLength, 11);
        },
      );
      test(
        "t3",
        () async {
          final q = StreamQueue(Stream.fromIterable([0x15, 0x80, 0x01]));
          final (t, streamEnded, _) = await MqttFixedHeader.fromStreamQueue(q);
          expect(t, isNotNull);
          expect(t!.packetType, MqttPacketType.connect);
          expect(t.flags, 0x05);
          expect(t.remainingLength, 128);
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
