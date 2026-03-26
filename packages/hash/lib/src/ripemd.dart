part of hash;

/// An instance of [RIPEMD160].
class RIPEMD160 extends BlockHash {
  @override
  int blockSize = 512;
  @override
  int padLength = 64;
  @override
  int outSize = 20;
  @override
  Endian endian = Endian.little;

  final List<int> _h = List.filled(5, 0);

  @override
  void reset() {
    super.reset();
    _h[0] = 0x67452301;
    _h[1] = 0xefcdab89;
    _h[2] = 0x98badcfe;
    _h[3] = 0x10325476;
    _h[4] = 0xc3d2e1f0;
  }

  @override
  void _update(List<int> msg, int start) {
    var A = _h[0];
    var B = _h[1];
    var C = _h[2];
    var D = _h[3];
    var E = _h[4];
    var Ah = A;
    var Bh = B;
    var Ch = C;
    var Dh = D;
    var Eh = E;
    for (var j = 0; j < 80; j++) {
      var T = _sum32(
          _rotl32(_sum32(A, _f(j, B, C, D), msg[_r[j] + start], _K(j)), _s[j]),
          E);
      A = E;
      E = D;
      D = _rotl32(C, 10);
      C = B;
      B = T;
      T = _sum32(
          _rotl32(
              _sum32(Ah, _f(79 - j, Bh, Ch, Dh), msg[_rh[j] + start], _Kh(j)),
              _sh[j]),
          Eh);
      Ah = Eh;
      Eh = Dh;
      Dh = _rotl32(Ch, 10);
      Ch = Bh;
      Bh = T;
    }
    var T = _sum32(_h[1], C, Dh);
    _h[1] = _sum32(_h[2], D, Eh);
    _h[2] = _sum32(_h[3], E, Ah);
    _h[3] = _sum32(_h[4], A, Bh);
    _h[4] = _sum32(_h[0], B, Ch);
    _h[0] = T;
  }

  @override
  Uint8List _digest() {
    return _split32(_h, endian);
  }
}

/// f
int _f(int j, int x, int y, int z) {
  if (j <= 15) {
    return x ^ y ^ z;
  } else if (j <= 31) {
    return (x & y) | ((~x) & z);
  } else if (j <= 47) {
    return (x | (~y)) ^ z;
  } else if (j <= 63) {
    return (x & z) | (y & (~z));
  } else {
    return x ^ (y | (~z));
  }
}

/// K
int _K(int j) {
  if (j <= 15) {
    return 0x00000000;
  } else if (j <= 31) {
    return 0x5a827999;
  } else if (j <= 47) {
    return 0x6ed9eba1;
  } else if (j <= 63) {
    return 0x8f1bbcdc;
  } else {
    return 0xa953fd4e;
  }
}

/// Kh
int _Kh(int j) {
  if (j <= 15) {
    return 0x50a28be6;
  } else if (j <= 31) {
    return 0x5c4dd124;
  } else if (j <= 47) {
    return 0x6d703ef3;
  } else if (j <= 63) {
    return 0x7a6d76e9;
  } else {
    return 0x00000000;
  }
}

List<int> _r = [
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 7, 4, 13, 1, 10, 6, //
  15, 3, 12, 0, 9, 5, 2, 14, 11, 8, 3, 10, 14, 4, 9, 15, 8, 1, 2, 7, 0, 6,
  13, 11, 5, 12, 1, 9, 11, 10, 0, 8, 12, 4, 13, 3, 7, 15, 14, 5, 6, 2, 4, 0,
  5, 9, 7, 12, 2, 10, 14, 1, 3, 8, 11, 6, 15, 13
];

List<int> _rh = [
  5, 14, 7, 0, 9, 2, 11, 4, 13, 6, 15, 8, 1, 10, 3, 12, 6, 11, 3, 7, 0, 13, //
  5, 10, 14, 15, 8, 12, 4, 9, 1, 2, 15, 5, 1, 3, 7, 14, 6, 9, 11, 8, 12, 2,
  10, 0, 4, 13, 8, 6, 4, 1, 3, 11, 15, 0, 5, 12, 2, 13, 9, 7, 10, 14, 12, 15,
  10, 4, 1, 5, 8, 7, 6, 2, 13, 14, 0, 3, 9, 11
];

List<int> _s = [
  11, 14, 15, 12, 5, 8, 7, 9, 11, 13, 14, 15, 6, 7, 9, 8, 7, 6, 8, 13, 11, //
  9, 7, 15, 7, 12, 15, 9, 11, 7, 13, 12, 11, 13, 6, 7, 14, 9, 13, 15, 14, 8,
  13, 6, 5, 12, 7, 5, 11, 12, 14, 15, 14, 15, 9, 8, 9, 14, 5, 6, 8, 6, 5, 12,
  9, 15, 5, 11, 6, 8, 13, 12, 5, 12, 13, 14, 11, 8, 5, 6
];

List<int> _sh = [
  8, 9, 9, 11, 13, 15, 15, 5, 7, 7, 8, 11, 14, 14, 12, 6, 9, 13, 15, 7, 12, //
  8, 9, 11, 7, 7, 12, 7, 6, 15, 13, 11, 9, 7, 15, 11, 8, 6, 6, 14, 12, 13,
  5, 14, 13, 13, 7, 5, 15, 5, 8, 11, 14, 14, 6, 14, 6, 9, 12, 9, 12, 5, 15,
  8, 8, 5, 12, 9, 12, 5, 14, 6, 8, 13, 6, 5, 15, 13, 11, 11
];
