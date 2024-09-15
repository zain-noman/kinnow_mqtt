import 'package:cutie_mqtt/src/byte_utils.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';

class MqttFixedHeader {
  final MqttPacketType packetType;
  final int flags;
  final int remainingLength;

  static ParseResult<MqttFixedHeader>? fromBytes(Iterable<int> bytes) {
    if (bytes.length < 2) return null;
    if (bytes.elementAt(0) >> 4 > MqttPacketType.values.length) return null;
    final MqttFixedHeader data = MqttFixedHeader(
      MqttPacketType.values[bytes.elementAt(0) >> 4],
      bytes.elementAt(0) & 0x0F,
      bytes.elementAt(1),
    );
    return ParseResult(
        data: data, nextBlockStart: bytes.skip(2), bytesConsumed: 2);
  }

  List<int> toBytes() {
    assert(remainingLength < 256);
    assert(flags < 0x0F);
    return [(packetType.index << 4) | (flags & 0x0F), remainingLength & 0xFF];
  }

  MqttFixedHeader(this.packetType, this.flags, this.remainingLength);
}
