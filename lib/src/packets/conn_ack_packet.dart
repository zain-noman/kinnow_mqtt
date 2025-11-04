import '../byte_utils.dart';
import '../mqtt_qos.dart';

/// The Reason codes that can be sent in the ConnAck packet according to the specification
enum ConnectReasonCode {
  success,
  unspecifiedError,
  malformedPacket,
  protocolError,
  implementationSpecificError,
  unsupportedProtocolVersion,
  clientIdentifierNotValid,
  badUserNameOrPassword,
  notAuthorized,
  serverUnavailable,
  serverBusy,
  banned,
  badAuthenticationMethod,
  topicNameInvalid,
  packetTooLarge,
  quotaExceeded,
  payloadFormatInvalid,
  retainNotSupported,
  qosNotSupported,
  useAnotherServer,
  serverMoved,
  connectionRateExceeded
}

/// A packet sent by the broker to thr client in response to a connection request
class ConnAckPacket {
  /// indicates if the broker had an existing session for the clientId
  final bool sessionPresent;

  /// the reason code indicates if the connection was successful or not along with a reason
  final ConnectReasonCode connectReasonCode;

  /// the server will delete the 'state' of the client after network disconnection plus this duration in seconds
  final int? sessionExpiryInterval;

  /// the maximum number of in progress QoS1 and QoS2 messages that the broker can handle at a time
  ///
  /// the library does not currently use this value to limit the message rate
  final int? receiveMaximum;

  /// the maximum QoS supported by the broker
  ///
  /// the library does not use this internally. the user should ensure that
  /// he/she only uses QoS that is supported by the broker
  final MqttQos? maximumQOS;

  /// whether the broker supports the retain functionality
  final bool? retainAvailable;

  /// the maximum packet size that the broker will accept. if a larger message is sent, the broker will disconnect
  ///
  /// the library does not use this value internally.
  final int? maxPacketSize;

  /// clientId assigned by the broker.
  ///
  /// This may be sent when an empty client id is sent by the client in connect
  /// packet and the broker assigns a client id
  final String? assignedClientId;

  /// the maximum number of topics aliases supported by broker
  ///
  /// the library does not use this value internally. user should ensure aliases
  /// are supported by the broker and how many
  final int? topicAliasMaximum;

  /// a human readable string sent by the broker for information
  final String? reasonString;

  /// custom properties
  final Map<String, String> userProperties;

  /// whether the broker supports wildcard subscriptions. if value is null then wildcard subscriptions are supported
  final bool? wildcardSubscriptionAvailable;

  /// whether the broker supports subscription identifiers. if value is null then subscription identifiers are supported
  final bool? subscriptionIdentifiersAvailable;

  /// whether the broker supports shared subscriptions. if value is null then shared subscriptions are supported
  final bool? sharedSubscriptionAvailable;

  /// keep alive time assigned by server
  final int? serverKeepAlive;

  /// a string with information on how to create response topics. The format of this is not standardised
  final String? responseInformation;

  /// provides information another server to use.
  final String? serverReference;

  /// name of authentication method
  final String? authMethod;

  /// binary data used for authentication
  final List<int>? authData;

  static const Map<int, ConnectReasonCode> _reasonCodeLookup = {
    0x00: ConnectReasonCode.success,
    0x80: ConnectReasonCode.unspecifiedError,
    0x81: ConnectReasonCode.malformedPacket,
    0x82: ConnectReasonCode.protocolError,
    0x83: ConnectReasonCode.implementationSpecificError,
    0x84: ConnectReasonCode.unsupportedProtocolVersion,
    0x85: ConnectReasonCode.clientIdentifierNotValid,
    0x86: ConnectReasonCode.badUserNameOrPassword,
    0x87: ConnectReasonCode.notAuthorized,
    0x88: ConnectReasonCode.serverUnavailable,
    0x89: ConnectReasonCode.serverBusy,
    0x8A: ConnectReasonCode.banned,
    0x8C: ConnectReasonCode.badAuthenticationMethod,
    0x90: ConnectReasonCode.topicNameInvalid,
    0x95: ConnectReasonCode.packetTooLarge,
    0x97: ConnectReasonCode.quotaExceeded,
    0x99: ConnectReasonCode.payloadFormatInvalid,
    0x9A: ConnectReasonCode.retainNotSupported,
    0x9B: ConnectReasonCode.qosNotSupported,
    0x9C: ConnectReasonCode.useAnotherServer,
    0x9D: ConnectReasonCode.serverMoved,
    0x9F: ConnectReasonCode.connectionRateExceeded
  };

  // bytes will not include the fixedHeader and
  // must only include the bytes of the packet
  static ConnAckPacket? fromBytes(Iterable<int> bytes) {
    bool sessionPresent;
    ConnectReasonCode connectReasonCode;

    int? sessionExpiryInterval;
    int? receiveMaximum;
    MqttQos? maximumQOS;
    bool? retainAvailable;
    int? maxPacketSize;
    String? assignedClientId;
    int? topicAliasMaximum;
    String? reasonString;
    Map<String, String> userProperties = {};
    bool? wildcardSubscriptionAvailable;
    bool? subscriptionIdentifiersAvailable;
    bool? sharedSubscriptionAvailable;
    int? serverKeepAlive;
    String? responseInformation;
    String? serverReference;
    String? authMethod;
    List<int>? authData;

    sessionPresent = bytes.elementAt(0) == 0x01;
    final reasonCodeTemp = _reasonCodeLookup[bytes.elementAt(1)];
    if (reasonCodeTemp == null) return null;
    connectReasonCode = reasonCodeTemp;
    final propertyLenRes = ByteUtils.parseVarLengthInt(bytes.skip(2))!;
    Iterable<int> currentBlock = propertyLenRes.nextBlockStart;
    int bytesDone = 0;
    while (bytesDone < propertyLenRes.data) {
      final propertyId = currentBlock.elementAt(0);
      ParseResult parseRes;

      // ignore: unnecessary_cast
switch (propertyId as int) {
  case 0x11:
    {
      final parseResTemp = ByteUtils.parseFourByte(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      sessionExpiryInterval = parseRes.data as int?;
      break;
    }
  case 0x21:
    {
      final parseResTemp = ByteUtils.parseTwoByte(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      receiveMaximum = parseRes.data as int?;
      break;
    }
  case 0x24:
    {
      parseRes = ParseResult(
        data: currentBlock.elementAt(1),
        bytesConsumed: 1,
        nextBlockStart: currentBlock.skip(2),
      );
      maximumQOS = MqttQos.values[currentBlock.elementAt(1)];
      break;
    }
  case 0x25:
    {
      parseRes = ParseResult(
        data: currentBlock.elementAt(1),
        bytesConsumed: 1,
        nextBlockStart: currentBlock.skip(2),
      );
      retainAvailable = currentBlock.elementAt(1) == 1;
      break;
    }
  case 0x27:
    {
      final parseResTemp = ByteUtils.parseFourByte(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      maxPacketSize = parseRes.data as int?;
      break;
    }
  case 0x12:
    {
      final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      assignedClientId = parseRes.data as String?;
      break;
    }
  case 0x22:
    {
      final parseResTemp = ByteUtils.parseTwoByte(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      topicAliasMaximum = parseRes.data as int?;
      break;
    }
  case 0x1F:
    {
      final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      reasonString = parseRes.data as String?;
      break;
    }
  case 0x26:
    {
      final parseResTemp = ByteUtils.parseStringPair(currentBlock);
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      userProperties.addEntries([parseRes.data]);
      break;
    }
  case 0x28:
    {
      parseRes = ParseResult(
        data: currentBlock.elementAt(1),
        bytesConsumed: 1,
        nextBlockStart: currentBlock.skip(2),
      );
      wildcardSubscriptionAvailable = currentBlock.elementAt(1) == 1;
      break;
    }
  case 0x29:
    {
      parseRes = ParseResult(
        data: currentBlock.elementAt(1),
        bytesConsumed: 1,
        nextBlockStart: currentBlock.skip(2),
      );
      subscriptionIdentifiersAvailable = currentBlock.elementAt(1) == 1;
      break;
    }
  case 0x2A:
    {
      parseRes = ParseResult(
        data: currentBlock.elementAt(1),
        bytesConsumed: 1,
        nextBlockStart: currentBlock.skip(2),
      );
      sharedSubscriptionAvailable = currentBlock.elementAt(1) == 1;
      break;
    }
  case 0x13:
    {
      final parseResTemp = ByteUtils.parseTwoByte(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      serverKeepAlive = parseRes.data as int?;
      break;
    }
  case 0x1A:
    {
      final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      reasonString = parseRes.data as String?;
      break;
    }
  case 0x1c:
    {
      final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      serverReference = parseResTemp.data as String?;
      break;
    }
  case 0x15:
    {
      final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      authMethod = parseResTemp.data as String?;
      break;
    }
  case 0x16:
    {
      final parseResTemp = ByteUtils.parseBinaryData(currentBlock.skip(1));
      if (parseResTemp == null) return null;
      parseRes = parseResTemp;
      authData = parseRes.data as List<int>?;
      break;
    }
  default:
    {
      return null;
    }
}
bytesDone += 1 + (parseRes.bytesConsumed ?? 0);
currentBlock = parseRes.nextBlockStart;

    }

    return ConnAckPacket(
      sessionPresent,
      connectReasonCode,
      sessionExpiryInterval,
      receiveMaximum,
      maximumQOS,
      retainAvailable,
      maxPacketSize,
      assignedClientId,
      topicAliasMaximum,
      reasonString,
      userProperties,
      wildcardSubscriptionAvailable,
      subscriptionIdentifiersAvailable,
      sharedSubscriptionAvailable,
      serverKeepAlive,
      responseInformation,
      serverReference,
      authMethod,
      authData,
    );
  }

  ConnAckPacket(
    this.sessionPresent,
    this.connectReasonCode,
    this.sessionExpiryInterval,
    this.receiveMaximum,
    this.maximumQOS,
    this.retainAvailable,
    this.maxPacketSize,
    this.assignedClientId,
    this.topicAliasMaximum,
    this.reasonString,
    this.userProperties,
    this.wildcardSubscriptionAvailable,
    this.subscriptionIdentifiersAvailable,
    this.sharedSubscriptionAvailable,
    this.serverKeepAlive,
    this.responseInformation,
    this.serverReference,
    this.authMethod,
    this.authData,
  );
}
