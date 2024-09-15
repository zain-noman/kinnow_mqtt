import 'package:cutie_mqtt/src/byte_utils.dart';
import 'package:cutie_mqtt/src/mqtt_fixed_header.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';

class ConnectPacketWillProperties {
  final MqttQos qos;
  final bool retain;
  final String willTopic;
  final StringOrBytes willPayload;

  //optional properties
  final int? willDelayInterval;
  final MqttFormatIndicator? format;
  final int? expiryInterval;
  final String? contentType;
  final String? responseTopic;
  final List<int>? correlationData;
  final Map<String, String>? userProperties;

  List<int> propertiesBytes() {
    final props = <int>[];
    ByteUtils.appendOptionalFourByteProperty(willDelayInterval, 0x18, props);
    if (format != null) {
      props.addAll([0x01, format!.index]);
    }
    ByteUtils.appendOptionalFourByteProperty(expiryInterval, 0x02, props);
    if (contentType != null) {
      props.addAll([0x03, ...ByteUtils.makeUtf8StringBytes(contentType!)]);
    }
    if (responseTopic != null) {
      props.addAll([0x08, ...ByteUtils.makeUtf8StringBytes(responseTopic!)]);
    }
    ByteUtils.appendBinaryDataProperty(correlationData, 0x09, props);
    ByteUtils.appendStringPairProperty(userProperties, 0x26, props);
    return [...ByteUtils.makeVariableByteInteger(props.length), ...props];
  }

  ConnectPacketWillProperties(
    this.qos,
    this.retain,
    this.willTopic,
    this.willPayload, {
    this.willDelayInterval,
    this.format,
    this.expiryInterval,
    this.contentType,
    this.responseTopic,
    this.correlationData,
    this.userProperties,
  });
}

class ConnectPacket {
  final int protocolVersion;
  bool cleanStart;
  final ConnectPacketWillProperties? lastWill;
  final int keepAliveSeconds;

  //clientId
  final String? username;
  final StringOrBytes? password;

  //optional properties
  final int? sessionExpiryIntervalSeconds;
  final int? receiveMaximum;
  final int? maxRecvPacketSize;
  final int? topicAliasMax;
  final bool? requestResponseInformation;
  final bool? requestProblemInformation;
  final Map<String, String>? userProperties;
  final String? authMethod;
  final List<int>? authData;

  ConnectPacket({
    required this.cleanStart,
    required this.lastWill,
    required this.keepAliveSeconds,
    required this.username,
    required this.password,
    this.protocolVersion = 5,
    this.sessionExpiryIntervalSeconds,
    this.receiveMaximum,
    this.maxRecvPacketSize,
    this.topicAliasMax,
    this.requestResponseInformation,
    this.requestProblemInformation,
    this.userProperties,
    this.authMethod,
    this.authData,
  });

  List<int> toBytes(String clientId) {
    assert(keepAliveSeconds <= 0xFFFF);

    final properties = List<int>.empty(growable: true);
    ByteUtils.appendOptionalFourByteProperty(
        sessionExpiryIntervalSeconds, 0x11, properties);
    ByteUtils.appendOptionalTwoByteProperty(receiveMaximum, 0x21, properties);
    ByteUtils.appendOptionalFourByteProperty(
        maxRecvPacketSize, 0x27, properties);
    ByteUtils.appendOptionalTwoByteProperty(topicAliasMax, 0x22, properties);
    if (requestResponseInformation != null) {
      properties.addAll([0x19, (requestResponseInformation!) ? 1 : 0]);
    }
    if (requestProblemInformation != null) {
      properties.addAll([0x17, (requestProblemInformation!) ? 1 : 0]);
    }
    ByteUtils.appendStringPairProperty(userProperties, 0x26, properties);
    if (authMethod != null) {
      properties.addAll([0x15, ...ByteUtils.makeUtf8StringBytes(authMethod!)]);
    }
    ByteUtils.appendBinaryDataProperty(authData, 0x16, properties);

    final body = <int>[
      // protocol name
      0, 4, ...("MQTT".codeUnits),
      protocolVersion,

      //connect flags,
      (((cleanStart ? 1 : 0) << 1) |
          ((lastWill == null ? 0 : 1) << 2) |
          ((lastWill == null ? 0 : lastWill!.qos.index) << 3) |
          ((lastWill == null ? 0 : (lastWill!.retain ? 1 : 0)) << 5) |
          ((password == null ? 0 : 1) << 6) |
          ((username == null ? 0 : 1) << 7)),
      keepAliveSeconds >> 8, keepAliveSeconds & 0xFF,

      properties.length,
      ...properties,

      //payload
      ...ByteUtils.makeUtf8StringBytes(clientId),
      if (lastWill != null) ...lastWill!.propertiesBytes(),
      if (lastWill != null)
        ...ByteUtils.makeUtf8StringBytes(lastWill!.willTopic),
      if (lastWill != null)
        ...ByteUtils.prependBinaryDataLength(lastWill!.willPayload.asBytes),
      if (username != null) ...ByteUtils.makeUtf8StringBytes(username!),
      if (password != null)
        ...ByteUtils.prependBinaryDataLength(password!.asBytes),
    ];
    final retVal =
        MqttFixedHeader(MqttPacketType.connect, 0, body.length).toBytes();
    retVal.addAll(body);
    return retVal;
  }
}
