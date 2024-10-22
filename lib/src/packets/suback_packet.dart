import '../byte_utils.dart';

/// success or failure reason for a topic subscription
enum SubackReasonCode {
  grantedQoS0,
  grantedQoS1,
  grantedQoS2,
  unspecifiedError,
  implementationSpecificError,
  notAuthorized,
  topicFilterInvalid,
  packetIdentifierInUse,
  quotaExceeded,
  sharedSubscriptionsNotSupported,
  subscriptionIdentifiersNotSupported,
  wildcardSubscriptionsNotSupported,
}

/// Packet sent by server in response to a [SubscribePacket]
class SubackPacket {
  /// packet id used to match a [SubscribePacket] to a corresponding [SubackPacket]
  ///
  /// used internally. Irrelevant to end user
  final int packetId;

  /// Contains information of success or otherwise of each topic that was sent in the [SubscribePacket]
  ///
  /// The order of reasonCodes is the same as the order of [SubscribePacket.topics]
  final List<SubackReasonCode> reasonCodes;

  /// A human readable string for further information
  String? reasonString;

  /// custom properties
  Map<String, String> userProperties;

  SubackPacket(
      this.packetId, this.reasonCodes, this.reasonString, this.userProperties);

  static const _byteToReasonCodeLookup = {
    0x00: SubackReasonCode.grantedQoS0,
    0x01: SubackReasonCode.grantedQoS1,
    0x02: SubackReasonCode.grantedQoS2,
    0x80: SubackReasonCode.unspecifiedError,
    0x83: SubackReasonCode.implementationSpecificError,
    0x87: SubackReasonCode.notAuthorized,
    0x8F: SubackReasonCode.topicFilterInvalid,
    0x91: SubackReasonCode.packetIdentifierInUse,
    0x97: SubackReasonCode.quotaExceeded,
    0x9E: SubackReasonCode.sharedSubscriptionsNotSupported,
    0xA1: SubackReasonCode.subscriptionIdentifiersNotSupported,
    0xA2: SubackReasonCode.wildcardSubscriptionsNotSupported,
  };

  static SubackPacket? fromBytes(Iterable<int> bytes) {
    final packetIdParseRes = ByteUtils.parseTwoByte(bytes);
    if (packetIdParseRes == null) return null;
    final packetId = packetIdParseRes.data;

    final propertyLenRes =
        ByteUtils.parseVarLengthInt(packetIdParseRes.nextBlockStart);
    if (propertyLenRes == null) return null;

    String? reasonString;
    final Map<String, String> userProperties = {};

    Iterable<int> currentBlock = propertyLenRes.nextBlockStart;
    int bytesDone = 0;
    while (bytesDone < propertyLenRes.data) {
      final propertyId = currentBlock.elementAt(0);
      ParseResult parseRes;
      switch (propertyId) {
        case 0x1F:
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
        default:
          {
            return null;
          }
      }
      bytesDone += 1 + parseRes.bytesConsumed;
      currentBlock = parseRes.nextBlockStart;
    }
    if (currentBlock.isEmpty) return null;
    List<SubackReasonCode> reasonCodes = [];
    for (final reasonCodeByte in currentBlock) {
      final code = _byteToReasonCodeLookup[reasonCodeByte];
      if (code == null) return null;
      reasonCodes.add(code);
    }

    return SubackPacket(packetId, reasonCodes, reasonString, userProperties);
  }
}
