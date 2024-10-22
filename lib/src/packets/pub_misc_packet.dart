import '../mqtt_fixed_header.dart';
import '../mqtt_packet_types.dart';

import '../byte_utils.dart';

class PubCommonPacket<T> {
  /// The packet Id used to match a packet with its response packet
  final int packetId;

  /// the reason
  final T? reasonCode;

  /// An optional human readable string for further information
  final String? reasonString;

  /// custom properties
  final Map<String, String> userProperties;

  /// used internally. ignore
  final Map<T, int> toByteLookup;

  /// used internally. ignore
  final Map<int, T> fromByteLookup;

  PubCommonPacket(this.packetId, this.reasonCode, this.reasonString,
      this.userProperties, this.toByteLookup, this.fromByteLookup);

  static PubCommonPacket<TT>? fromBytes<TT>(Iterable<int> bytes,
      Map<TT, int> toByteLookup, Map<int, TT> fromByteLookup) {
    final packetIdParseRes = ByteUtils.parseTwoByte(bytes);
    if (packetIdParseRes == null) return null;
    final packetId = packetIdParseRes.data;
    if (packetIdParseRes.nextBlockStart.isEmpty) {
      return PubCommonPacket(
          packetId, null, null, const {}, toByteLookup, fromByteLookup);
    }

    final reasonCode =
        fromByteLookup[packetIdParseRes.nextBlockStart.elementAt(0)];
    if (reasonCode == null) return null;

    // no property length
    if (packetIdParseRes.nextBlockStart.length == 1) {
      return PubCommonPacket(
          packetId, reasonCode, null, const {}, toByteLookup, fromByteLookup);
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
    return PubCommonPacket(packetId, reasonCode, reasonString, userProperties,
        toByteLookup, fromByteLookup);
  }

  List<int> toBytesInternal(MqttPacketType type) {
    final props = <int>[];
    if (reasonString != null) {
      props.add(0x1F);
      props.addAll(ByteUtils.makeUtf8StringBytes(reasonString!));
    }
    ByteUtils.appendStringPairProperty(userProperties, 0x26, props);

    final body = <int>[
      (packetId >> 8) & 0xFF,
      packetId & 0xFF,
      if (reasonCode != null) toByteLookup[reasonCode]!,
      if (props.isNotEmpty) ...ByteUtils.makeVariableByteInteger(props.length),
      if (props.isNotEmpty) ...props,
    ];
    return [...MqttFixedHeader(type, 0, body.length).toBytes(), ...body];
  }
}

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

typedef PubrecReasonCode = PubackReasonCode;

const _byteToPubackReasonCodeLookup = {
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

const _pubackReasonCodeToByteLookup = {
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

enum PubrelReasonCode {
  success,
  packetIdentifierNotFound;
}

typedef PubcompReasonCode = PubrelReasonCode;

const _byteToPubrelReasonCodeLookup = {
  0x00: PubrelReasonCode.success,
  0x92: PubrelReasonCode.packetIdentifierNotFound
};
const _pubrelReasonCodeToByteLookup = {
  PubrelReasonCode.success: 0x00,
  PubrelReasonCode.packetIdentifierNotFound: 0x92,
};

/// Packet sent in response to a QoS1 message
class PubackPacket extends PubCommonPacket<PubackReasonCode> {
  PubackPacket(int packetId, PubackReasonCode? reasonCode, String? reasonString,
      Map<String, String> userProperties)
      : super(packetId, reasonCode, reasonString, userProperties,
            _pubackReasonCodeToByteLookup, _byteToPubackReasonCodeLookup);

  static PubackPacket? fromBytes(Iterable<int> bytes) {
    final res = PubCommonPacket.fromBytes(
        bytes, _pubackReasonCodeToByteLookup, _byteToPubackReasonCodeLookup);
    if (res == null) return null;
    return PubackPacket(
        res.packetId, res.reasonCode, res.reasonString, res.userProperties);
  }

  List<int> toBytes() => toBytesInternal(MqttPacketType.puback);
}

/// Packet sent in response to a QoS2 Publish message
class PubrecPacket extends PubCommonPacket<PubackReasonCode> {
  PubrecPacket(int packetId, PubackReasonCode? reasonCode, String? reasonString,
      Map<String, String> userProperties)
      : super(packetId, reasonCode, reasonString, userProperties,
            _pubackReasonCodeToByteLookup, _byteToPubackReasonCodeLookup);

  static PubrecPacket? fromBytes(Iterable<int> bytes) {
    final res = PubCommonPacket.fromBytes(
        bytes, _pubackReasonCodeToByteLookup, _byteToPubackReasonCodeLookup);
    if (res == null) return null;
    return PubrecPacket(
        res.packetId, res.reasonCode, res.reasonString, res.userProperties);
  }

  List<int> toBytes() => toBytesInternal(MqttPacketType.pubrec);
}

/// Sent in response to a [PubrecPacket] for Qos2 messages
class PubrelPacket extends PubCommonPacket<PubrelReasonCode> {
  PubrelPacket(int packetId, PubrelReasonCode? reasonCode, String? reasonString,
      Map<String, String> userProperties)
      : super(packetId, reasonCode, reasonString, userProperties,
            _pubrelReasonCodeToByteLookup, _byteToPubrelReasonCodeLookup);

  static PubrelPacket? fromBytes(Iterable<int> bytes) {
    final res = PubCommonPacket.fromBytes(
        bytes, _pubrelReasonCodeToByteLookup, _byteToPubrelReasonCodeLookup);
    if (res == null) return null;
    return PubrelPacket(
        res.packetId, res.reasonCode, res.reasonString, res.userProperties);
  }

  List<int> toBytes() => toBytesInternal(MqttPacketType.pubrel);
}

/// Sent in response to a [PubrelPacket] for Qos2 messages
class PubcompPacket extends PubCommonPacket<PubrelReasonCode> {
  PubcompPacket(int packetId, PubcompReasonCode? reasonCode,
      String? reasonString, Map<String, String> userProperties)
      : super(packetId, reasonCode, reasonString, userProperties,
            _pubrelReasonCodeToByteLookup, _byteToPubrelReasonCodeLookup);

  static PubcompPacket? fromBytes(Iterable<int> bytes) {
    final res = PubCommonPacket.fromBytes(
        bytes, _pubrelReasonCodeToByteLookup, _byteToPubrelReasonCodeLookup);
    if (res == null) return null;
    return PubcompPacket(
        res.packetId, res.reasonCode, res.reasonString, res.userProperties);
  }

  List<int> toBytes() => toBytesInternal(MqttPacketType.pubcomp);
}
