import 'dart:convert';
import 'dart:typed_data';

class ParseResult<T> {
  final T data;
  final Iterable<int> nextBlockStart;
  final int bytesConsumed;

  ParseResult({
    required this.data,
    required this.bytesConsumed,
    required this.nextBlockStart,
  });
}

class StringOrBytes {
  List<int>? _bytes;
  String? _string;

  StringOrBytes.fromString(String str) {
    _string = str;
  }

  StringOrBytes.fromBytes(List<int> bytes) {
    _bytes = bytes;
  }

  List<int> get asBytes {
    if (_bytes != null) return _bytes!;
    _bytes = utf8.encode(_string!);
    return _bytes!;
  }

  String get asString {
    if (_string != null) return _string!;
    _string = utf8.decode(_bytes!);
    return _string!;
  }
}

class ByteUtils {
  static List<int> makeUtf8StringBytes(String val) {
    ///TODO: Fix 0xFEEF problem
    final encoded = utf8.encode(val);
    return [
      (encoded.length >> 8 & 0xFF),
      (encoded.length & 0xFF),
      ...encoded,
    ];
  }

  static List<int> makeVariableByteInteger(int val) {
    final retVal = <int>[];
    do {
      int encodedByte = val % 128;
      val = val ~/ 128;
      if (val > 0) {
        encodedByte |= 0x80;
      }
      retVal.add(encodedByte);
    } while (val > 0);
    return retVal;
  }

  static List<int> prependBinaryDataLength(List<int> val) {
    return [val.length >> 8 & 0xFF, val.length & 0xFF, ...val];
  }

  static void appendOptionalFourByteProperty(
      int? val, int propertyId, List<int> list) {
    if (val == null) return;

    list.addAll([
      propertyId,
      ...(ByteData(4)..setUint32(0, val, Endian.big)).buffer.asUint8List()
    ]);
  }

  static void appendOptionalTwoByteProperty(
      int? val, int propertyId, List<int> list) {
    if (val == null) return;

    list.addAll([
      propertyId,
      ...(ByteData(2)..setUint16(0, val, Endian.big)).buffer.asUint8List()
    ]);
  }

  static void appendStringPairProperty(
      Map<String, String>? val, int propertyId, List<int> list) {
    if (val == null) return;

    for (final entry in val.entries) {
      list.addAll([
        propertyId,
        ...makeUtf8StringBytes(entry.key),
        ...makeUtf8StringBytes(entry.value),
      ]);
    }
  }

  static void appendBinaryDataProperty(
      List<int>? val, int propertyId, List<int> list) {
    if (val == null) return;

    list.addAll(
        [propertyId, val.length >> 8 & 0xFF, val.length & 0xFF, ...val]);
  }

  static ParseResult<String>? mqttParseUtf8(Iterable<int> data) {
    if (data.length < 2) return null;
    int strlen = data.elementAt(0) * 255 + data.elementAt(1);
    if (data.length < 2 + strlen) return null;

    // implementation based on implementation by Bjoern Hoehrmann slightly
    // modified for the mqtt spec. Dart's own utf8 decode is based on this
    // See http://bjoern.hoehrmann.de/utf-8/decoder/dfa/ for details.
    const charTypeLookup = <int>[
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, // 00..1f
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, // 20..3f
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, // 40..5f
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, // 60..7f
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9,
      9, 9, 9, 9, 9, 9, 9, // 80..9f
      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
      7, 7, 7, 7, 7, 7, 7, // a0..bf
      8, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
      2, 2, 2, 2, 2, 2, 2, // c0..df
      0xa, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x4, 0x3,
      0x3, // e0..ef
      0xb, 0x6, 0x6, 0x6, 0x5, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8,
      0x8, // f0..ff
    ];

    const stateLookup = <int>[
      0x0, 0x1, 0x2, 0x3, 0x5, 0x8, 0x7, 0x1, 0x1, 0x1, 0x4, 0x6, 0x1, 0x1, 0x1,
      0x1, // s0..s0
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1,
      0, 1, 1, 1, 1, 1, 1, // s1..s2
      1, 2, 1, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1,
      1, 1, 1, 1, 1, 1, 1, // s3..s4
      1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1,
      3, 1, 1, 1, 1, 1, 1, // s5..s6
      1, 3, 1, 1, 1, 1, 1, 3, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1,
      1, 1, 1, 1, 1, 1, 1, // s7..s8
    ];
    const utf8Accept = 0;

    int state = utf8Accept;
    final codePoints = <int>[];

    for (final i in data.skip(2).take(strlen)) {
      if (i >= 0 && i <= 0x1F) return null;

      if (i >= 0x7F && i <= 0x9F) return null;

      int type = charTypeLookup[i];

      if (state == utf8Accept) codePoints.add(0);

      codePoints.last = (state != utf8Accept)
          ? (i & 0x3f) | (codePoints.last << 6)
          : (0xff >> type) & i;

      state = stateLookup[16 * state + type];
    }
    return ParseResult(
        data: String.fromCharCodes(codePoints),
        bytesConsumed: 2 + strlen,
        nextBlockStart: data.skip(2 + strlen));
  }

  static ParseResult<int>? parseVarLengthInt(Iterable<int> data) {
    int multiplier = 1;
    int value = 0;
    int i = 0;
    while (true) {
      if (i >= 4 || i >= data.length) return null;
      value += (data.elementAt(i) & 0x7F) * multiplier;
      if (data.elementAt(i) < 127) break;
      multiplier *= 128;
      i++;
    }
    return ParseResult(
        data: value, nextBlockStart: data.skip(i + 1), bytesConsumed: i + 1);
  }

  static ParseResult<int>? parseFourByte(Iterable<int> block) {
    if (block.length < 4) return null;
    final data = Uint8List.fromList(block.take(4).toList());
    final blob = ByteData.sublistView(data);

    return ParseResult(
        data: blob.getUint32(0, Endian.big),
        nextBlockStart: block.skip(4),
        bytesConsumed: 4);
  }

  static ParseResult<int>? parseTwoByte(Iterable<int> block) {
    if (block.length < 2) return null;
    final data = Uint8List.fromList(block.take(2).toList());
    final blob = ByteData.sublistView(data);

    return ParseResult(
        data: blob.getUint16(0, Endian.big),
        nextBlockStart: block.skip(2),
        bytesConsumed: 2);
  }

  static ParseResult<MapEntry<String, String>>? parseStringPair(
      Iterable<int> block) {
    final keyRes = ByteUtils.mqttParseUtf8(block);
    //malformed strings
    if (keyRes == null) return null;
    final valueRes = ByteUtils.mqttParseUtf8(keyRes.nextBlockStart);
    if (valueRes == null) return null;
    return ParseResult(
      data: MapEntry(keyRes.data, valueRes.data),
      nextBlockStart: valueRes.nextBlockStart,
      bytesConsumed: keyRes.bytesConsumed + valueRes.bytesConsumed,
    );
  }

  static ParseResult<List<int>>? parseBinaryData(Iterable<int> block) {
    if (block.length < 2) return null;
    final dataLen = block.elementAt(0) * 255 + block.elementAt(1);
    if (block.length < 2 + dataLen) return null;
    return ParseResult(
      data: block.skip(2).take(dataLen).toList(),
      nextBlockStart: block.skip(2 + dataLen),
      bytesConsumed: 2 + dataLen,
    );
  }
}
