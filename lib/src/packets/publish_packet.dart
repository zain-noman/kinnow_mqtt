import '../byte_utils.dart';
import '../mqtt_fixed_header.dart';
import '../mqtt_packet_types.dart';
import '../mqtt_qos.dart';

// user facing class
class TxPublishPacket {
  final bool retain;
  final String topic;
  final StringOrBytes payload;

  final MqttFormatIndicator? payloadFormat;
  final int? messageExpiryInterval;
  final bool useAlias;
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
    this.useAlias = false,
  });
}

abstract class TopicAliasManager {
  int? getTxTopicAlias(String topic);

  int createTxTopicAlias(String topic);

  void createRxTopicAlias(String topic, int alias);

  String? getTopicForRxAlias(int alias);
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
      final aliasNullable = aliasMgr.getTxTopicAlias(userData.topic);
      if (aliasNullable != null) {
        alias = aliasNullable;
        topic = "";
      } else {
        alias = aliasMgr.createTxTopicAlias(topic);
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

class RxPublishPacket {
  final bool retain;
  final String topic;
  final StringOrBytes payload;
  final MqttQos qos;
  final bool isDuplicate;
  final int? packetId;

  final MqttFormatIndicator? payloadFormat;
  final int? messageExpiryInterval;
  final bool aliasUsed;
  final String? responseTopic;
  final List<int>? correlationData;
  final Map<String, String> userProperties;
  final String? contentType;
  final int? subscriptionId;

  RxPublishPacket(
    this.retain,
    this.topic,
    this.payload,
    this.qos,
    this.payloadFormat,
    this.messageExpiryInterval,
    this.aliasUsed,
    this.responseTopic,
    this.correlationData,
    this.userProperties,
    this.contentType,
    this.subscriptionId,
    this.isDuplicate,
    this.packetId,
  );

  static (RxPublishPacket?, bool topicAliasIssue) fromBytes(
      Iterable<int> bytes, int flags, TopicAliasManager topicManager) {
    final isDuplicate = flags & 0x08 == 0x08;
    final qosVal = ((flags >> 1) & 0x03);
    if (qosVal > 2) return (null, false);
    final qos = MqttQos.values[qosVal];
    final retain = flags & 0x01 == 0x01;

    final topicNameParse = ByteUtils.mqttParseUtf8(bytes);
    if (topicNameParse == null) return (null, false);
    String topic = topicNameParse.data;

    Iterable<int> currentBlock = topicNameParse.nextBlockStart;
    int? packetId;
    if (qos != MqttQos.atMostOnce) {
      final packetIdParse =
          ByteUtils.parseTwoByte(topicNameParse.nextBlockStart);
      if (packetIdParse == null) return (null, false);
      packetId = packetIdParse.data;
      currentBlock = packetIdParse.nextBlockStart;
    }

    final propertyLenRes = ByteUtils.parseVarLengthInt(currentBlock);
    if (propertyLenRes == null) return (null, false);

    MqttFormatIndicator? payloadFormat;
    int? messageExpiryInterval;
    bool aliasUsed = false;
    String? responseTopic;
    List<int>? correlationData;
    final Map<String, String> userProperties = {};
    String? contentType;
    int? subscriptionId;

    currentBlock = propertyLenRes.nextBlockStart;
    int bytesDone = 0;
    while (bytesDone < propertyLenRes.data) {
      final propertyId = currentBlock.elementAt(0);
      ParseResult parseRes;
      switch (propertyId) {
        case 0x01:
          if (currentBlock.length < 2) return (null, false);
          {
            parseRes = ParseResult(
              data: currentBlock.elementAt(1),
              bytesConsumed: 1,
              nextBlockStart: currentBlock.skip(2),
            );
            payloadFormat = (currentBlock.elementAt(1) == 1)
                ? MqttFormatIndicator.bytes
                : MqttFormatIndicator.utf8;
          }
        case 0x02:
          {
            final parseResTemp = ByteUtils.parseFourByte(currentBlock.skip(1));
            if (parseResTemp == null) return (null, false);
            messageExpiryInterval = parseResTemp.data;
            parseRes = parseResTemp;
          }
        case 0x23:
          {
            final parseResTemp = ByteUtils.parseTwoByte(currentBlock.skip(1));
            if (parseResTemp == null) return (null, false);
            final alias = parseResTemp.data;
            if (topic.isEmpty) {
              final actualTopic = topicManager.getTopicForRxAlias(alias);
              if (actualTopic == null) return (null, true);
              aliasUsed = true;
              topic = actualTopic;
            } else {
              topicManager.createRxTopicAlias(topic, alias);
            }
            parseRes = parseResTemp;
          }
        case 0x08:
          {
            final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
            if (parseResTemp == null) return (null, false);
            responseTopic = parseResTemp.data;
            parseRes = parseResTemp;
          }
        case 0x09:
          {
            final parseResTemp =
                ByteUtils.parseBinaryData(currentBlock.skip(1));
            if (parseResTemp == null) return (null, false);
            correlationData = parseResTemp.data;
            parseRes = parseResTemp;
          }
        case 0x26:
          {
            final parseResTemp =
                ByteUtils.parseStringPair(currentBlock.skip(1));
            if (parseResTemp == null) return (null, false);
            userProperties.addEntries([parseResTemp.data]);
            parseRes = parseResTemp;
          }
        case 0x0B:
          {
            final parseResTemp =
                ByteUtils.parseVarLengthInt(currentBlock.skip(1));
            if (parseResTemp == null) return (null, false);
            subscriptionId = parseResTemp.data;
            parseRes = parseResTemp;
          }
        case 0x03:
          {
            final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
            if (parseResTemp == null) return (null, false);
            contentType = parseResTemp.data;
            parseRes = parseResTemp;
          }
        default:
          {
            return (null, false);
          }
      }
      bytesDone += 1 + parseRes.bytesConsumed;
      currentBlock = parseRes.nextBlockStart;
    }
    final payload = StringOrBytes.fromBytes(currentBlock.toList());
    return (
      RxPublishPacket(
          retain,
          topic,
          payload,
          qos,
          payloadFormat,
          messageExpiryInterval,
          aliasUsed,
          responseTopic,
          correlationData,
          userProperties,
          contentType,
          subscriptionId,
          isDuplicate,
          packetId),
      false
    );
  }
}
