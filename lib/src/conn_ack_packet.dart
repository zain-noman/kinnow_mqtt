import 'package:cutie_mqtt/src/byte_utils.dart';
import 'package:cutie_mqtt/src/mqtt_qos.dart';

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

class ConnAckPacket {
  final bool sessionPresent;
  final ConnectReasonCode connectReasonCode;

  final int? sessionExpiryInterval;
  final int? receiveMaximum;
  final MqttQos? maximumQOS;
  final bool? retainAvailable;
  final int? maxPacketSize;
  final String? assignedClientId;
  final int? topicAliasMaximum;
  final String? reasonString;
  final Map<String, String> userProperties;
  final bool? wildcardSubscriptionAvailable;
  final bool? subscriptionIdentifiersAvailable;
  final bool? sharedSubscriptionAvailable;
  final int? serverKeepAlive;
  final String? responseInformation;
  final String? serverReference;
  final String? authMethod;
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
    connectReasonCode = _reasonCodeLookup[bytes.elementAt(1)]!;
    final propertyLenRes = ByteUtils.parseVarLengthInt(bytes.skip(2))!;
    Iterable<int> currentBlock = propertyLenRes.nextBlockStart;
    int bytesDone = 0;
    while (bytesDone < propertyLenRes.data) {
      final propertyId = currentBlock.elementAt(0);
      ParseResult parseRes;
      switch (propertyId) {
        case 0x11:
          {
            final parseResTemp = ByteUtils.parseFourByte(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            sessionExpiryInterval = parseRes.data;
          }
        case 0x21:
          {
            final parseResTemp = ByteUtils.parseTwoByte(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            receiveMaximum = parseRes.data;
          }
        case 0x24:
          {
            parseRes = ParseResult(
              data: currentBlock.elementAt(1),
              bytesConsumed: 1,
              nextBlockStart: currentBlock.skip(2),
            );
            maximumQOS = MqttQos.values[currentBlock.elementAt(1)];
          }
        case 0x25:
          {
            parseRes = ParseResult(
              data: currentBlock.elementAt(1),
              bytesConsumed: 1,
              nextBlockStart: currentBlock.skip(2),
            );
            retainAvailable = currentBlock.elementAt(1) == 1;
          }
        case 0x27:
          {
            final parseResTemp = ByteUtils.parseFourByte(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            maxPacketSize = parseRes.data;
          }
        case 0x12:
          {
            final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            assignedClientId = parseRes.data;
          }
        case 0x22:
          {
            final parseResTemp = ByteUtils.parseTwoByte(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            topicAliasMaximum = parseRes.data;
          }
        case 0x31:
          {
            final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            reasonString = parseRes.data;
          }
        case 0x26:
          {
            final parseResTemp = ByteUtils.parseStringPair(currentBlock);
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            userProperties.addEntries([parseRes.data]);
          }
        case 0x28:
          {
            parseRes = ParseResult(
              data: currentBlock.elementAt(1),
              bytesConsumed: 1,
              nextBlockStart: currentBlock.skip(2),
            );
            wildcardSubscriptionAvailable = currentBlock.elementAt(1) == 1;
          }
        case 0x29:
          {
            parseRes = ParseResult(
              data: currentBlock.elementAt(1),
              bytesConsumed: 1,
              nextBlockStart: currentBlock.skip(2),
            );
            subscriptionIdentifiersAvailable = currentBlock.elementAt(1) == 1;
          }
        case 0x2A:
          {
            parseRes = ParseResult(
              data: currentBlock.elementAt(1),
              bytesConsumed: 1,
              nextBlockStart: currentBlock.skip(2),
            );
            sharedSubscriptionAvailable = currentBlock.elementAt(1) == 1;
          }
        case 0x13:
          {
            final parseResTemp = ByteUtils.parseTwoByte(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            serverKeepAlive = parseRes.data;
          }
        case 0x1A:
          {
            final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            reasonString = parseRes.data;
          }
        case 0x1c:
          {
            final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            serverReference = parseResTemp.data;
          }
        case 0x15:
          {
            final parseResTemp = ByteUtils.mqttParseUtf8(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            authMethod = parseResTemp.data;
          }
        case 0x16:
          {
            final parseResTemp = ByteUtils.parseBinaryData(currentBlock.skip(1));
            if (parseResTemp == null) return null;
            parseRes = parseResTemp;
            authData = parseRes.data;
          }
        default:
          {
            return null;
          }
      }
      bytesDone += 1 + parseRes.bytesConsumed;
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
