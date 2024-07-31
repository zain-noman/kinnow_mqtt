import 'package:cutie_mqtt/src/byte_utils.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';
import 'package:test/test.dart';

void main() {
  group(
    "Byte Utils Tests",
    () {
      test(
        "fixed header",
        () {
          expect(ByteUtils.makeFixedHeader(MqttPacketType.connect, 0x0A, 2),
              [0x1A, 2]);
        },
      );
      test(
        "makeUtf8StringBytes",
        () {
          expect(ByteUtils.makeUtf8StringBytes("hello"),
              [0x00, 0x05, 0x68, 0x65, 0x6c, 0x6c, 0x6f]);
          expect(ByteUtils.makeUtf8StringBytes(String.fromCharCodes([0xFEEF])),
              [0, 3, 0xEF, 0xBB, 0xBF]);
        },
      );
      test(
        "makeVariableByteInteger",
        () {
          expect(ByteUtils.makeVariableByteInteger(126), [126]);
          expect(ByteUtils.makeVariableByteInteger(128), [0x80, 01]);
          expect(ByteUtils.makeVariableByteInteger(129), [0x81, 01]);
        },
      );
      test(
        "appendProperty",
        () {
          {
            final list = <int>[0xaa, 0xbb, 0xcc];
            ByteUtils.appendOptionalFourByteProperty(12, 0x11, list);
            expect(list, [0xaa, 0xbb, 0xcc, 0x11, 00, 00, 00, 12]);
            ByteUtils.appendOptionalFourByteProperty(null, 0x11, list);
            expect(list, [0xaa, 0xbb, 0xcc, 0x11, 00, 00, 00, 12]);
          }

          {
            final list = <int>[0xaa, 0xbb, 0xcc];
            ByteUtils.appendOptionalTwoByteProperty(12, 0x11, list);
            expect(list, [0xaa, 0xbb, 0xcc, 0x11, 00, 12]);
            ByteUtils.appendOptionalTwoByteProperty(null, 0x11, list);
            expect(list, [0xaa, 0xbb, 0xcc, 0x11, 00, 12]);
          }

          {
            final strProps = {"key1": "val1", "key2": "val2"};
            final list = <int>[0xaa, 0xbb, 0xcc];
            ByteUtils.appendStringPairProperty(null, 0x11, list);
            expect(list,[0xaa, 0xbb, 0xcc]);
            ByteUtils.appendStringPairProperty(strProps, 0x11, list);
            expect(list, [
              0xaa, 0xbb, 0xcc,
              0x11,0x00,0x04, ..."key1".codeUnits, 0x00,0x04, ..."val1".codeUnits,
              0x11,0x00,0x04, ..."key2".codeUnits, 0x00,0x04, ..."val2".codeUnits
            ]);
          }
        },
      );
    },
  );
}
