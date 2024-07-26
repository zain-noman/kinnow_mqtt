import 'package:cutie_mqtt/src/data_parsing.dart';
import 'package:test/test.dart';

void main() {
  test(
    "test if utf8.decode is suitable for mqtt",
    () {
      expect(parseVarLengthInt([0x05])?.data, 5);
      expect(parseVarLengthInt([0x15])?.data, 0x15);

      expect(parseVarLengthInt([0xff, 0x01])?.data, 255);
      expect(parseVarLengthInt([0xff, 0xff, 0xff, 0xff])?.data, null);

      expect(parseVarLengthInt([0xff, 0xff])?.data, null);
      expect(parseVarLengthInt([0xff, 0xff, 0xff, 0xff, 0x01])?.data, null);

      expect(parseVarLengthInt([0xff, 0x01, 0xaa, 0xbb])?.data, 255);
      expect(parseVarLengthInt([0xff, 0x01, 0xaa, 0xbb])?.nextBlockStart,
          containsAllInOrder([0xaa, 0xbb]));
      expect(parseVarLengthInt([0xff, 0x01, 0xaa, 0xbb])?.nextBlockStart,
          isNot(contains([0xaa, 0xbb])));
    },
  );
}
