import 'package:cutie_mqtt/src/mqtt_fixed_header.dart';
import 'package:cutie_mqtt/src/mqtt_packet_types.dart';

import '../byte_utils.dart';

enum PubackReasonCode {
  success,
  noMatchingSubscribers,
  unspecifiedError,
  implementationSpecificError,
  notAuthorized,
  topicNameInvalid,
  packetIdentifierInUse,
  quotaExceeded,
  payloadFormatInvalid,
}

class PubackPacket {
  final int packetId;
  final PubackReasonCode? reasonCode;
  String? reasonString;
  Map<String, String> userProperties;

  PubackPacket(
      this.packetId, this.reasonCode, this.reasonString, this.userProperties);

  static const _byteToReasonCodeLookup = {
    0x00: PubackReasonCode.success,
    0x10: PubackReasonCode.noMatchingSubscribers,
    0x80: PubackReasonCode.unspecifiedError,
    0x83: PubackReasonCode.implementationSpecificError,
    0x87: PubackReasonCode.notAuthorized,
    0x90: PubackReasonCode.topicNameInvalid,
    0x91: PubackReasonCode.packetIdentifierInUse,
    0x97: PubackReasonCode.quotaExceeded,
    0x99: PubackReasonCode.payloadFormatInvalid,
  };

  static const _reasonCodeToByteLookup = {
    PubackReasonCode.success: 0x00,
    PubackReasonCode.noMatchingSubscribers: 0x10,
    PubackReasonCode.unspecifiedError: 0x80,
    PubackReasonCode.implementationSpecificError: 0x83,
    PubackReasonCode.notAuthorized: 0x87,
    PubackReasonCode.topicNameInvalid: 0x90,
    PubackReasonCode.packetIdentifierInUse: 0x91,
    PubackReasonCode.quotaExceeded: 0x97,
    PubackReasonCode.payloadFormatInvalid: 0x99,
  };

  static PubackPacket? fromBytes(Iterable<int> bytes) {
    final packetIdParseRes = ByteUtils.parseTwoByte(bytes);
    if (packetIdParseRes == null) return null;
    final packetId = packetIdParseRes.data;
    if (packetIdParseRes.nextBlockStart.isEmpty) {
      return PubackPacket(packetId, null, null, const {});
    }

    final reasonCode =
        _byteToReasonCodeLookup[packetIdParseRes.nextBlockStart.elementAt(0)];
    if (reasonCode == null) return null;

    // no property length
    if (packetIdParseRes.nextBlockStart.length == 1) {
      return PubackPacket(packetId, reasonCode, null, const {});
    }

    final propertyLenRes =
        ByteUtils.parseVarLengthInt(packetIdParseRes.nextBlockStart.skip(1));
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
    return PubackPacket(packetId, reasonCode, reasonString, userProperties);
  }

  List<int> toBytes() {

    final props = <int>[];
    if (reasonString !=null){
      props.add(0x1F);
      props.addAll(ByteUtils.makeUtf8StringBytes(reasonString!));
    }
    ByteUtils.appendStringPairProperty(userProperties, 0x26, props);

    final body = <int>[
      (packetId >> 8) & 0xFF,
      packetId & 0xFF,
      if(reasonCode!=null)
        _reasonCodeToByteLookup[reasonCode]!,
      if(props.isNotEmpty)
        ...ByteUtils.makeVariableByteInteger(props.length),
      if(props.isNotEmpty)
        ...props,
    ];
    return [
      ...MqttFixedHeader(MqttPacketType.puback, 0, body.length).toBytes(),
      ...body
    ];
  }
}
