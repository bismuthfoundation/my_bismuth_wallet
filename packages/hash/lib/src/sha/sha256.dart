part of hash;

/// An instance of [SHA256].
class SHA256 extends BlockHash {
  @override
  int blockSize = 512;
  @override
  int padLength = 64;
  @override
  int outSize = 32;
  final List<int> _h = List.filled(8, 0);
  final List<int> _k = _sha256_K;
  final List<int> _W = List.filled(64, 0);

  @override
  void reset() {
    super.reset();
    _h[0] = 0x6a09e667;
    _h[1] = 0xbb67ae85;
    _h[2] = 0x3c6ef372;
    _h[3] = 0xa54ff53a;
    _h[4] = 0x510e527f;
    _h[5] = 0x9b05688c;
    _h[6] = 0x1f83d9ab;
    _h[7] = 0x5be0cd19;
  }

  @override
  void _update(List<int> msg, int start) {
    var i = 0;
    for (i = 0; i < 16; i++) {
      _W[i] = msg[start + i];
    }
    for (; i < _W.length; i++) {
      _W[i] = _sum32(
          _g1_256(_W[i - 2]), _W[i - 7], _g0_256(_W[i - 15]), _W[i - 16]);
    }

    var a = _h[0];
    var b = _h[1];
    var c = _h[2];
    var d = _h[3];
    var e = _h[4];
    var f = _h[5];
    var g = _h[6];
    var h = _h[7];

    assert(_W.length == _W.length);
    for (i = 0; i < _W.length; i++) {
      var T1 = _sum32(h, _s1_256(e), _ch32(e, f, g), _k[i], _W[i]);
      var T2 = _sum32(_s0_256(a), _maj32(a, b, c));
      h = g;
      g = f;
      f = e;
      e = _sum32(d, T1);
      d = c;
      c = b;
      b = a;
      a = _sum32(T1, T2);
    }

    _h[0] = _sum32(_h[0], a);
    _h[1] = _sum32(_h[1], b);
    _h[2] = _sum32(_h[2], c);
    _h[3] = _sum32(_h[3], d);
    _h[4] = _sum32(_h[4], e);
    _h[5] = _sum32(_h[5], f);
    _h[6] = _sum32(_h[6], g);
    _h[7] = _sum32(_h[7], h);
  }

  @override
  Uint8List _digest() {
    return _split32(_h, endian);
  }
}

List<int> _sha256_K = <int>[
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, //
  0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
  0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
  0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
  0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
  0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
];
