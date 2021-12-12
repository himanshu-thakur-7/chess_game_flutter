Map<int?, int?> decodeBoard() {
  Map<int?, int?> decodings = {};

  for (var i = 0; i < 64; i++) {
    decodings[i] = 63 - i;
  }

  return decodings;
}
