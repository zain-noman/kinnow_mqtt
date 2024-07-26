class ParseResult<T> {
  T data;
  Iterable<int> nextBlockStart;

  ParseResult({required this.data, required this.nextBlockStart});
}

ParseResult<String>? mqttParseUtf8(Iterable<int> data) {
  assert(data.length > 2);
  int strlen = data.elementAt(0) * 255 + data.elementAt(1);

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
  const UTF8_ACCEPT = 0;

  int state = UTF8_ACCEPT;
  final codePoints = <int>[];

  for (final i in data.skip(2).take(strlen)) {
    if (i >= 0 && i <= 0x1F) return null;

    if (i >= 0x7F && i <= 0x9F) return null;

    int type = charTypeLookup[i];

    if (state == UTF8_ACCEPT) codePoints.add(0);

    codePoints.last = (state != UTF8_ACCEPT)
        ? (i & 0x3f) | (codePoints.last << 6)
        : (0xff >> type) & i;

    state = stateLookup[16 * state + type];
  }
  return ParseResult(
      data: String.fromCharCodes(codePoints),
      nextBlockStart: data.skip(2 + strlen));
}

ParseResult<int>? parseVarLengthInt(Iterable<int> data) {
  int multiplier = 1;
  int value = 0;
  int i = 0;
  while (true) {}
  value += data.elementAt(i) * multiplier;
  return ParseResult(data: value, nextBlockStart: data.skip(i));
}
