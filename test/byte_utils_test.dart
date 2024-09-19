import 'package:kinnow_mqtt/src/byte_utils.dart';
import 'package:test/test.dart';

void main() {
  group(
    "Byte Utils Tests",
    () {
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
            expect(list, [0xaa, 0xbb, 0xcc]);
            ByteUtils.appendStringPairProperty(strProps, 0x11, list);
            expect(list, [
              0xaa,
              0xbb,
              0xcc,
              0x11,
              0x00,
              0x04,
              ..."key1".codeUnits,
              0x00,
              0x04,
              ..."val1".codeUnits,
              0x11,
              0x00,
              0x04,
              ..."key2".codeUnits,
              0x00,
              0x04,
              ..."val2".codeUnits
            ]);
          }
        },
      );
      test(
        "Parsing",
        () {
          {
            final t1 = ByteUtils.parseFourByte([1, 2, 3, 4, 5, 6, 7]);
            expect(t1!.data, 16909060);
            expect(t1.nextBlockStart, [5, 6, 7]);
          }

          {
            final t2 = ByteUtils.parseTwoByte([1, 2, 3, 4, 5, 6, 7]);
            expect(t2!.data, 258);
            expect(t2.nextBlockStart, [3, 4, 5, 6, 7]);
          }
          {
            final t3 = ByteUtils.parseStringPair([
              0,
              5,
              0x68,
              0x65,
              0x6c,
              0x6c,
              0x6f,
              0,
              2,
              0x68,
              0x69,
              1,
              2,
              3,
              4,
              5
            ]);
            expect(t3, isNotNull);
            expect(t3!.data.key, 'hello');
            expect(t3.data.value, 'hi');
            expect(t3.nextBlockStart, [1, 2, 3, 4, 5]);
            expect(t3.bytesConsumed, 11);
          }
          {
            final t3 = ByteUtils.parseStringPair([0, 0, 0, 0, 1, 2, 3, 4, 5]);
            expect(t3, isNotNull);
            expect(t3!.data.key, isEmpty);
            expect(t3.data.value, isEmpty);
            expect(t3.nextBlockStart, [1, 2, 3, 4, 5]);
            expect(t3.bytesConsumed, 4);
          }
          {
            final t3 = ByteUtils.parseBinaryData(
                [0, 5, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 1, 2, 3, 4, 5]);
            expect(t3!.data, [0x68, 0x65, 0x6c, 0x6c, 0x6f]);
            expect(t3.bytesConsumed, 7);
            expect(t3.nextBlockStart, [1, 2, 3, 4, 5]);
          }
        },
      );
      test(
        "Parsing with less length",
        () {
          {
            final t1 = ByteUtils.parseFourByte([1, 2]);
            expect(t1, isNull);
          }
          {
            final t2 = ByteUtils.parseTwoByte([1]);
            expect(t2, isNull);
          }
          {
            final t3 = ByteUtils.parseStringPair([
              0,
              5,
              0x68,
              0x65,
              0x6c,
              0x6c,
              0x6f,
              0,
              2,
              0x68,
            ]);
            expect(t3, isNull);
          }
          {
            final t3 = ByteUtils.parseBinaryData([
              0,
              5,
              0x68,
              0x65,
            ]);
            expect(t3, isNull);
          }
          {
            final t3 = ByteUtils.parseBinaryData([0, 1]);
            expect(t3, isNull);
          }
        },
      );
    },
  );
}
