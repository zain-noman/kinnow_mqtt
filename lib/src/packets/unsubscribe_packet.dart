import '../byte_utils.dart';
import '../mqtt_fixed_header.dart';
import '../mqtt_packet_types.dart';

/// Packet sent by client to unsubscribe from one or more topics
class UnsubscribePacket {
  /// custom properties
  final Map<String, String> userProperties;
  /// The topics to unsubscribe from
  final List<String> topicFilters;

  /// Create unsubscribe packet
  ///
  /// [topicFilters] is a list of topics to unsubscribe from
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
