import '../mqtt_qos.dart';
import 'package:isar/isar.dart';
import '../packets/publish_packet.dart';
import '../byte_utils.dart';

part 'tx_publish_pkt_isar.g.dart';

@collection
class TxPublishPktIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  MqttQos qos;

  bool retain;
  String topic;
  List<byte> payload;

  @Enumerated(EnumType.ordinal32)
  MqttFormatIndicator? payloadFormat;

  int? messageExpiryInterval;
  bool useAlias;
  String? responseTopic;
  List<byte>? correlationData;
  List<String> userPropertiesKeys;
  List<String> userPropertiesValues;
  String? contentType;

  TxPublishPktIsar(
    this.qos,
    this.retain,
    this.topic,
    this.payload,
    this.payloadFormat,
    this.messageExpiryInterval,
    this.useAlias,
    this.responseTopic,
    this.correlationData,
    this.userPropertiesKeys,
    this.userPropertiesValues,
    this.contentType,
  );

  TxPublishPktIsar.fromPacket(TxPublishPacket pkt, this.qos)
      : retain = pkt.retain,
        topic = pkt.topic,
        payload = pkt.payload.asBytes,
        payloadFormat = pkt.payloadFormat,
        messageExpiryInterval = pkt.messageExpiryInterval,
        useAlias = pkt.useAlias,
        responseTopic = pkt.responseTopic,
        correlationData = pkt.correlationData,
        userPropertiesKeys = pkt.userProperties.keys.toList(),
        userPropertiesValues = pkt.userProperties.values.toList(),
        contentType = pkt.contentType;

  TxPublishPacket toPkt() {
    return TxPublishPacket(
      retain,
      topic,
      StringOrBytes.fromBytes(payload),
      userProperties: Map<String, String>.fromIterables(
        userPropertiesKeys,
        userPropertiesValues,
      ),
      contentType: contentType,
      correlationData: correlationData,
      messageExpiryInterval: messageExpiryInterval,
      payloadFormat: payloadFormat,
      responseTopic: responseTopic,
      useAlias: useAlias,
    );
  }
}
