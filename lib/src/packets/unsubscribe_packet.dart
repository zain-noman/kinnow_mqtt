import '../byte_utils.dart';
import '../mqtt_fixed_header.dart';
import '../mqtt_packet_types.dart';

class UnsubscribePacket {
  final Map<String, String> userProperties;
  final List<String> topicFilters;

  UnsubscribePacket(this.topicFilters,
      {this.userProperties = const <String, String>{}});
}

class InternalUnsubscribePacket {
  final int packetId;
  final UnsubscribePacket unSub;

  InternalUnsubscribePacket(this.packetId, this.unSub);

  List<int> toBytes() {
    final props = <int>[];
    ByteUtils.appendStringPairProperty(unSub.userProperties, 0x26, props);
    final body = <int>[
      packetId >> 8,
      packetId & 0xFF,
      ...ByteUtils.makeVariableByteInteger(props.length),
      ...props
    ];
    for (final topicFilter in unSub.topicFilters) {
      body.addAll(ByteUtils.makeUtf8StringBytes(topicFilter));
    }
    return [
      ...MqttFixedHeader(MqttPacketType.unsubscribe, 2, body.length).toBytes(),
      ...body
    ];
  }
}
