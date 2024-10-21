import '../byte_utils.dart';
import '../mqtt_fixed_header.dart';
import '../mqtt_packet_types.dart';

/// The Disconnection Reason provided by the server or the client in the disconnect packet
enum DisconnectReasonCode {
  normal,
  disconnectWithWill,
  unspecified,
  malformedPacket,
  protocolError,
  implementationSpecificError,
  notAuthorized,
  serverBusy,
  serverShuttingDown,
  keepAliveTimeout,
  sessionTakenOver,
  topicFilterInvalid,
  topicNameInvalid,
  receiveMaximumExceeded,
  topicAliasInvalid,
  packetTooLarge,
  messageRateTooHigh,
  quotaExceeded,
  administrativeAction,
  payloadFormatInvalid,
  retainNotSupported,
  qosNotSupported,
  useAnotherServer,
  serverMoved,
  sharedSubscriptionsNotSupported,
  connectionRateExceeded,
  maximumConnectTime,
  subscriptionIdentifiersNotSupported,
  wildcardSubscriptionsNotSupported,
}

/// A packet sent by the server or client to close the connection
class DisconnectPacket {
  static const _byteToReasonCode = {
    0x00: DisconnectReasonCode.normal,
    0x04: DisconnectReasonCode.disconnectWithWill,
    0x80: DisconnectReasonCode.unspecified,
    0x81: DisconnectReasonCode.malformedPacket,
    0x82: DisconnectReasonCode.protocolError,
    0x83: DisconnectReasonCode.implementationSpecificError,
    0x87: DisconnectReasonCode.notAuthorized,
    0x89: DisconnectReasonCode.serverBusy,
    0x8B: DisconnectReasonCode.serverShuttingDown,
    0x8D: DisconnectReasonCode.keepAliveTimeout,
    0x8E: DisconnectReasonCode.sessionTakenOver,
    0x8F: DisconnectReasonCode.topicFilterInvalid,
    0x90: DisconnectReasonCode.topicNameInvalid,
    0x93: DisconnectReasonCode.receiveMaximumExceeded,
    0x94: DisconnectReasonCode.topicAliasInvalid,
    0x95: DisconnectReasonCode.packetTooLarge,
    0x96: DisconnectReasonCode.messageRateTooHigh,
    0x97: DisconnectReasonCode.quotaExceeded,
    0x98: DisconnectReasonCode.administrativeAction,
    0x99: DisconnectReasonCode.payloadFormatInvalid,
    0x9A: DisconnectReasonCode.retainNotSupported,
    0x9B: DisconnectReasonCode.qosNotSupported,
    0x9C: DisconnectReasonCode.useAnotherServer,
    0x9D: DisconnectReasonCode.serverMoved,
    0x9E: DisconnectReasonCode.sharedSubscriptionsNotSupported,
    0x9F: DisconnectReasonCode.connectionRateExceeded,
    0xA0: DisconnectReasonCode.maximumConnectTime,
    0xA1: DisconnectReasonCode.subscriptionIdentifiersNotSupported,
    0xA2: DisconnectReasonCode.wildcardSubscriptionsNotSupported,
  };
  static const _reasonCodeToByte = {
    DisconnectReasonCode.normal: 0x00,
    DisconnectReasonCode.disconnectWithWill: 0x04,
    DisconnectReasonCode.unspecified: 0x80,
    DisconnectReasonCode.malformedPacket: 0x81,
    DisconnectReasonCode.protocolError: 0x82,
    DisconnectReasonCode.implementationSpecificError: 0x83,
    DisconnectReasonCode.notAuthorized: 0x87,
    DisconnectReasonCode.serverBusy: 0x89,
    DisconnectReasonCode.serverShuttingDown: 0x8B,
    DisconnectReasonCode.keepAliveTimeout: 0x8D,
    DisconnectReasonCode.sessionTakenOver: 0x8E,
    DisconnectReasonCode.topicFilterInvalid: 0x8F,
    DisconnectReasonCode.topicNameInvalid: 0x90,
    DisconnectReasonCode.receiveMaximumExceeded: 0x93,
    DisconnectReasonCode.topicAliasInvalid: 0x94,
    DisconnectReasonCode.packetTooLarge: 0x95,
    DisconnectReasonCode.messageRateTooHigh: 0x96,
    DisconnectReasonCode.quotaExceeded: 0x97,
    DisconnectReasonCode.administrativeAction: 0x98,
    DisconnectReasonCode.payloadFormatInvalid: 0x99,
    DisconnectReasonCode.retainNotSupported: 0x9A,
    DisconnectReasonCode.qosNotSupported: 0x9B,
    DisconnectReasonCode.useAnotherServer: 0x9C,
    DisconnectReasonCode.serverMoved: 0x9D,
    DisconnectReasonCode.sharedSubscriptionsNotSupported: 0x9E,
    DisconnectReasonCode.connectionRateExceeded: 0x9F,
    DisconnectReasonCode.maximumConnectTime: 0xA0,
    DisconnectReasonCode.subscriptionIdentifiersNotSupported: 0xA1,
    DisconnectReasonCode.wildcardSubscriptionsNotSupported: 0xA2,
  };

  /// create a [DisconnectPacket] from bytes
  static DisconnectPacket? fromBytes(Iterable<int> data) {
    final reasonCode = _byteToReasonCode[data.elementAt(0)];
    if (reasonCode == null) return null;
    final propsLen = ByteUtils.parseVarLengthInt(data.skip(1));
    if (propsLen == null) return null;

    Iterable<int> currentPropStart = propsLen.nextBlockStart;
    int bytesConsumed = 0;
    int? sessionExpInterval;
    String? reasonString;
    Map<String, String> userProps = {};
    String? serverReference;
    while (bytesConsumed < propsLen.data) {
      final propId = currentPropStart.elementAt(0);
      ParseResult? p;
      switch (propId) {
        case 0x11:
          p = ByteUtils.parseFourByte(currentPropStart.skip(1));
          if (p == null) return null;
          sessionExpInterval = p.data;
        case 0x1F:
          p = ByteUtils.mqttParseUtf8(currentPropStart.skip(1));
          if (p == null) return null;
          reasonString = p.data;
        case 0x1C:
          p = ByteUtils.mqttParseUtf8(currentPropStart.skip(1));
          if (p == null) return null;
          serverReference = p.data;
        case 0x26:
          p = ByteUtils.parseStringPair(currentPropStart.skip(1));
          if (p == null) return null;
          userProps.addEntries(p.data);
        default:
          return null;
      }
      bytesConsumed += 1 + p.bytesConsumed;
      currentPropStart = p.nextBlockStart;
    }
    return DisconnectPacket(reasonCode,
        reasonString: reasonString,
        serverReference: serverReference,
        sessionExpiryInterval: sessionExpInterval,
        userProperties: userProps);
  }

  /// Cause of disconnection
  final DisconnectReasonCode reasonCode;
  /// Time in seconds after which the server should delete the state of the client
  ///
  /// can only sent by client
  final int? sessionExpiryInterval;
  /// A human readable string to provide extra information
  final String? reasonString;
  /// custom properties
  final Map<String, String> userProperties;
  /// sent by server to inform client of some other server to use
  final String? serverReference;

 /// create a disconnect packet
  const DisconnectPacket(
    this.reasonCode, {
    this.sessionExpiryInterval,
    this.reasonString,
    this.userProperties = const {},
    this.serverReference,
  });

  /// convert to byte representation
  List<int> toBytes() {
    final props = <int>[];
    ByteUtils.appendOptionalFourByteProperty(
        sessionExpiryInterval, 0x11, props);
    if (reasonString != null) {
      props.addAll([0x1F, ...ByteUtils.makeUtf8StringBytes(reasonString!)]);
    }
    ByteUtils.appendStringPairProperty(userProperties, 0x26, props);
    if (serverReference != null) {
      props.addAll([0x1C, ...ByteUtils.makeUtf8StringBytes(serverReference!)]);
    }
    final body = [
      _reasonCodeToByte[reasonCode]!,
      ...ByteUtils.makeVariableByteInteger(props.length),
      ...props
    ];
    return [
      ...MqttFixedHeader(MqttPacketType.disconnect, 0, body.length).toBytes(),
      ...body
    ];
  }
}
