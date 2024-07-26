import 'package:cutie_mqtt/src/data_parsing.dart';
import 'package:test/test.dart';

void main() {
  test(
    "test if utf8.decode is suitable for mqtt",
    () {
      expect(
          mqttParseUtf8([0, 5, 0x68, 0x65, 0x6c, 0x6c, 0x6f])?.data, "hello");

      expect(
          mqttParseUtf8([0, 5, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0xaa, 0xbb, 0xcc])
              ?.data,
          "hello");

      expect(
          mqttParseUtf8([0, 5, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0xaa, 0xbb, 0xcc])
              ?.nextBlockStart,
          containsAllInOrder([0xaa, 0xbb, 0xcc]));

      expect(mqttParseUtf8([0, 6, 0x68, 0x65, 0x00, 0x6c, 0x6c, 0x6f])?.data,
          isNull);

      expect(mqttParseUtf8([0, 3, 0xEF, 0xBB, 0xBF])?.data.codeUnits.first,
          0xFEFF);
    },
  );
}
