import 'package:async/async.dart';
import 'byte_utils.dart';
import 'mqtt_packet_types.dart';

class MqttFixedHeader {
  final MqttPacketType packetType;
  final int flags;
  final int remainingLength;

  static Future<(MqttFixedHeader?, bool streamEnded, List<int>? malformedBytes)>
      fromStreamQueue(StreamQueue<int> queue) async {
    final bytesTaken = <int>[];
    try {
      final byte1 = await queue.next;
      bytesTaken.add(byte1);

      //parse var length int
      int multiplier = 1;
      int value = 0;
      int i = 0;
      while (true) {
        if (i >= 4) return (null, false, bytesTaken);
        final byte = await queue.next;
        bytesTaken.add(byte);
        value += (byte & 0x7F) * multiplier;
        if (byte < 127) break;
        multiplier *= 128;
        i++;
      }

      final fixedHdr = MqttFixedHeader(
          MqttPacketType.values[(byte1 >> 4)], byte1 & 0x0F, value);
      return (fixedHdr, false, bytesTaken);
    } on StateError {
      return (null, true, null);
    }
  }

  List<int> toBytes() {
    assert(flags < 0x0F);
    return [
      (packetType.index << 4) | (flags & 0x0F),
      ...ByteUtils.makeVariableByteInteger(remainingLength)
    ];
  }

  MqttFixedHeader(this.packetType, this.flags, this.remainingLength);

  static ParseResult<MqttFixedHeader>? fromBytes(Iterable<int> bytes) {
    if (bytes.length < 2) return null;

    final remLenRes = ByteUtils.parseVarLengthInt(bytes.skip(1));
    if (remLenRes == null) return null;

    final byte1 = bytes.elementAt(0);
    final fixedHdr = MqttFixedHeader(
        MqttPacketType.values[(byte1 >> 4)], byte1 & 0x0F, remLenRes.data);
    return ParseResult(
        data: fixedHdr,
        bytesConsumed: remLenRes.bytesConsumed + 1,
        nextBlockStart: remLenRes.nextBlockStart);
  }
}
