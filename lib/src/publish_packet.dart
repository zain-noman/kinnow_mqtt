import 'package:cutie_mqtt/src/byte_utils.dart';
import 'package:cutie_mqtt/src/mqtt_fixed_header.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';

// user facing class
class TxPublishPacket {
  final bool retain;
  final String topic;
  final StringOrBytes payload;

  final MqttFormatIndicator? payloadFormat;
  final int? messageExpiryInterval;
  final bool useAlias = false;
  final String? responseTopic;
  final List<int>? correlationData;
  final Map<String, String> userProperties;
  final String? contentType;

  TxPublishPacket(
    this.retain,
    this.topic,
    this.payload, {
    this.payloadFormat,
    this.messageExpiryInterval,
    this.responseTopic,
    this.correlationData,
    this.userProperties = const {},
    this.contentType,
  });
}

abstract class TopicAliasManager {
  int? getTopicAliasMapping(String topic);

  int createTopicAlias(String topic);
}

//for internal use only
class InternalTxPublishPacket {
  late final List<int> _bytes;
  List<int> get bytes => _bytes;

  bool _isDuplicate = false;

  bool get isDuplicate => _isDuplicate;

  set isDuplicate(bool isDup) {
    _isDuplicate = isDup;
    if (isDuplicate) {
      _bytes[0] |= 0x08;
    } else {
      _bytes[0] &= 0xF7;
    }
  }

  final int? packetId;
  final MqttQos qos;
  final TxPublishPacket userData;

  InternalTxPublishPacket(
    this.packetId,
    this.qos,
    this.userData,
    TopicAliasManager aliasMgr,
  ) {
    final props = <int>[];
    if (userData.payloadFormat != null) {
      props.addAll([0x01, userData.payloadFormat!.index]);
    }
    ByteUtils.appendOptionalFourByteProperty(
        userData.messageExpiryInterval, 0x02, props);

    String topic = userData.topic;
    if (userData.useAlias) {
      int alias;
      final aliasNullable = aliasMgr.getTopicAliasMapping(userData.topic);
      if (aliasNullable != null) {
        alias = aliasNullable;
        topic = "";
      } else {
        alias = aliasMgr.createTopicAlias(topic);
      }
      ByteUtils.appendOptionalTwoByteProperty(alias, 0x23, props);
    }
    if (userData.responseTopic != null) {
      props.addAll(
          [0x08, ...ByteUtils.makeUtf8StringBytes(userData.responseTopic!)]);
    }
    ByteUtils.appendBinaryDataProperty(userData.correlationData, 0x09, props);
    ByteUtils.appendStringPairProperty(userData.userProperties, 0x26, props);
    if (userData.contentType != null) {
      props.addAll(
          [0x03, ...ByteUtils.makeUtf8StringBytes(userData.contentType!)]);
    }

    final body = [
      ...ByteUtils.makeUtf8StringBytes(topic),
      if (packetId != null) ...[(packetId! >> 8) & 0xFF, packetId! & 0xFF],
      ...ByteUtils.makeVariableByteInteger(props.length),
      ...props,
      ...userData.payload.asBytes
    ];
    _bytes = [
      ...MqttFixedHeader(MqttPacketType.publish,
              qos.index << 1 | (userData.retain ? 1 : 0), body.length)
          .toBytes(),
      ...body,
    ];
  }
}

