import 'package:kinnow_mqtt/src/byte_utils.dart';
import 'package:test/test.dart';

void main() {
  test(
    "test if utf8.decode is suitable for mqtt",
    () {
      expect(ByteUtils.parseVarLengthInt([0x05])?.data, 5);
      expect(ByteUtils.parseVarLengthInt([0x15])?.data, 0x15);

      expect(ByteUtils.parseVarLengthInt([0xff, 0x01])?.data, 255);
      expect(ByteUtils.parseVarLengthInt([0xff, 0xff, 0xff, 0xff])?.data, null);

      expect(ByteUtils.parseVarLengthInt([0xff, 0xff])?.data, null);
      expect(ByteUtils.parseVarLengthInt([0xff, 0xff, 0xff, 0xff, 0x01])?.data,
          null);

      expect(ByteUtils.parseVarLengthInt([0xff, 0x01, 0xaa, 0xbb])?.data, 255);
      expect(
          ByteUtils.parseVarLengthInt([0xff, 0x01, 0xaa, 0xbb])?.nextBlockStart,
          containsAllInOrder([0xaa, 0xbb]));
      expect(
          ByteUtils.parseVarLengthInt([0xff, 0x01, 0xaa, 0xbb])?.nextBlockStart,
          isNot(contains([0xaa, 0xbb])));
    },
  );
}
