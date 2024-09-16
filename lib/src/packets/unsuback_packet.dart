import '../byte_utils.dart';

enum UnsubackReasonCode {
  success,
  noSubscriptionExisted,
  unspecifiedError,
  implementationSpecificError,
  notAuthorized,
  topicFilterInvalid,
  packetIdentifierInUse,
}

class UnsubackPacket {
  final int packetId;
  final List<UnsubackReasonCode> reasonCodes;
  String? reasonString;
  Map<String, String> userProperties;

  UnsubackPacket(this.packetId, this.reasonCodes, this.reasonString,
      this.userProperties);

  static const _byteToReasonCodeLookup = {
    0x00: UnsubackReasonCode.success,
    0x11: UnsubackReasonCode.noSubscriptionExisted,
    0x80: UnsubackReasonCode.unspecifiedError,
    0x83: UnsubackReasonCode.implementationSpecificError,
    0x87: UnsubackReasonCode.notAuthorized,
    0x8F: UnsubackReasonCode.topicFilterInvalid,
    0x91: UnsubackReasonCode.packetIdentifierInUse,
  };

  static UnsubackPacket? fromBytes(Iterable<int> bytes) {
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
    List<UnsubackReasonCode> reasonCodes = [];
    for (final reasonCodeByte in currentBlock) {
      final code = _byteToReasonCodeLookup[reasonCodeByte];
      if (code == null) return null;
      reasonCodes.add(code);
    }

    return UnsubackPacket(packetId, reasonCodes, reasonString, userProperties);
  }
}
