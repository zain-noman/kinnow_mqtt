import '../byte_utils.dart';
import '../mqtt_fixed_header.dart';
import '../mqtt_packet_types.dart';
import '../mqtt_qos.dart';

/// The Last Will Properties
///
/// The last will message is a message sent  by the broker on behalf of the client
/// after the client disconnects abruptly (without sending a disconnect packet)
/// the details of this message can only be specified at the time of connection
/// and cannot be altered later
class ConnectPacketWillProperties {
  /// The Quality Of Service to use
  final MqttQos qos;

  /// Whether the last will message should be retained
  final bool retain;

  /// The topic
  final String willTopic;

  /// The message payload
  final StringOrBytes willPayload;

  //optional properties
  /// duration in seconds after which the server will publish the last will message
  ///
  /// if the Session Expiry Interval is smaller than this value,
  /// then Session Expiry Interval will be used instead
  final int? willDelayInterval;

  /// whether the [willPayload] is binary data or string
  final MqttFormatIndicator? format;

  /// the message expiry interval of the will message.
  ///
  /// this will be received by other clients as part of [RxPublishPacket.messageExpiryInterval]
  final int? expiryInterval;

  /// see [TxPublishPacket.contentType]
  final String? contentType;

  /// see [TxPublishPacket.responseTopic]
  final String? responseTopic;

  /// see [TxPublishPacket.correlationData]
  final List<int>? correlationData;

  /// see [TxPublishPacket.userProperties]
  final Map<String, String>? userProperties;

  /// used internally. ignore
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

  /// create a Will Message.
  ///
  /// [qos] : the quality of service of the last will message
  /// [retain] : whether the last will message will be retained
  /// [willTopic] : the topic
  /// [willPayload] : the body of the last will message
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

/// The connect packet sent to initiate connection
class ConnectPacket {
  /// the protocol version
  ///
  /// the default value is MQTT 5. the library may also be compatible with
  /// future versions
  final int protocolVersion;

  /// if 'false', any previous state stored by the server is discarded, otherwise it is used
  bool cleanStart;

  /// the last will message properties, if null no last will message will be used
  final ConnectPacketWillProperties? lastWill;

  /// ping messages will be exchanged after this duration to test connection
  ///
  /// The server may request a different keep alive value in [ConnAckPacket.serverKeepAlive].
  /// In that case, the server's keep alive time will be used
  final int keepAliveSeconds;

  /// username for username + password based authentication
  final String? username;

  /// password for username + password based authentication. Does not necessarily need to be a string
  final StringOrBytes? password;

  //optional properties
  /// the server will delete the 'state' of the client this many seconds after network disconnection
  final int? sessionExpiryIntervalSeconds;

  /// the maximum number of in progress QoS1 and QoS2 messages that the client can handle at a time
  ///
  /// the library does not currently use this value to limit the message rate
  final int? receiveMaximum;

  /// messages larger than this size will not be forwarded by the broke to this client
  final int? maxRecvPacketSize;

  /// the maximum number of topics aliases to be used
  ///
  /// the library does not have any limit on aliases but user can limit them if he wants
  final int? topicAliasMax;

  /// if 'true' the server should send a [ConnAckPacket.responseInformation]
  final bool? requestResponseInformation;

  /// whether the server will send reason strings on packets
  final bool? requestProblemInformation;

  /// custom properties
  final Map<String, String>? userProperties;

  /// name of authentication method
  final String? authMethod;

  /// binary data used for authentication
  final List<int>? authData;

  /// create a Connect packet
  ///
  /// [cleanStart] : the last will message properties, if null no last will message will be used
  /// [lastWill] : the last will message properties, if null no last will message will be used
  /// [keepAliveSeconds] : ping messages will be exchanged after this duration to test connection
  /// [username] : username, can be set to null if not needed
  /// [password] : password, can be set to null if not needed
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

  /// used internally. ignore
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
