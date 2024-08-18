import 'package:cutie_mqtt/src/connect_packet.dart';
import 'package:cutie_mqtt/src/byte_utils.dart';
import 'package:test/test.dart';

void main() {
  group("connectPacket", () {
    test("compare toBytes basic", () {
      final expectedBytes = [
        0x10,
        0x0d,
        0x00,
        0x04,
        0x4d,
        0x51,
        0x54,
        0x54,
        0x05,
        0x02,
        0x00,
        0x3c,
        0x00,
        0x00,
        0x00
      ];
      final packet = ConnectPacket(
          cleanStart: true,
          lastWill: null,
          keepAliveSeconds: 60,
          username: null,
          password: null);

      expect(packet.toBytes(""), expectedBytes);
    });
    test("compare toBytes with actual clientId, username and password", () {
      final expectedBytes = [
        0x10,
        0x29,
        0x00,
        0x04,
        0x4d,
        0x51,
        0x54,
        0x54,
        0x05,
        0xc2,

        //keep alive
        0x00,
        0x3c,

        //client Id
        0x00,
        0x00,
        0x08,
        0x63,
        0x6c,
        0x69,
        0x65,
        0x6e,
        0x74,
        0x49,
        0x64,
        0x00,
        0x08,
        0x75,
        0x73,
        0x65,
        0x72,
        0x6e,
        0x61,
        0x6d,
        0x65,
        0x00,
        0x08,
        0x70,
        0x61,
        0x73,
        0x73,
        0x77,
        0x6f,
        0x72,
        0x64,
      ];
      final packet = ConnectPacket(
          cleanStart: true,
          lastWill: null,
          keepAliveSeconds: 60,
          username: "username",
          password: StringOrBytes.fromString("password"));

      expect(packet.toBytes("clientId"), expectedBytes);
    });
  });
}
