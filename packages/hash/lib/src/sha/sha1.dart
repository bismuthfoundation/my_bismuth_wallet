part of hash;

List<int> _sha1_K = <int>[0x5A827999, 0x6ED9EBA1, 0x8F1BBCDC, 0xCA62C1D6];

/// An instance of [SHA1].
class SHA1 extends BlockHash {
  @override
  int blockSize = 512;
  @override
  int padLength = 64;
  @override
  int outSize = 20;
  final List<int> _h = List.filled(5, 0);
  final List<int> _W = List.filled(80, 0);

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
    var i = 0;
    for (i = 0; i < 16; i++) {
      _W[i] = msg[start + i];
    }

    for (; i < _W.length; i++) {
      _W[i] = _rotl32(_W[i - 3] ^ _W[i - 8] ^ _W[i - 14] ^ _W[i - 16], 1);
    }

    var a = _h[0];
    var b = _h[1];
    var c = _h[2];
    var d = _h[3];
    var e = _h[4];

    for (i = 0; i < _W.length; i++) {
      var s = (i ~/ 20);
      var t = _sum32(_rotl32(a, 5), _ft_1(s, b, c, d), e, _W[i], _sha1_K[s]);
      e = d;
      d = c;
      c = _rotl32(b, 30);
      b = a;
      a = t;
    }

    _h[0] = _sum32(_h[0], a);
    _h[1] = _sum32(_h[1], b);
    _h[2] = _sum32(_h[2], c);
    _h[3] = _sum32(_h[3], d);
    _h[4] = _sum32(_h[4], e);
  }

  @override
  Uint8List _digest() {
    return _split32(_h, endian);
  }
}
