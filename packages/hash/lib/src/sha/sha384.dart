part of hash;

/// An instance of [SHA384].
class SHA384 extends SHA512 {
  @override
  int blockSize = 1024;
  @override
  int padLength = 128;
  @override
  int outSize = 48;
  @override
  final List<int> _h = List.filled(16, 0);

  @override
  void reset() {
    super.reset();
    _h[0] = 0xcbbb9d5d;
    _h[1] = 0xc1059ed8;
    _h[2] = 0x629a292a;
    _h[3] = 0x367cd507;
    _h[4] = 0x9159015a;
    _h[5] = 0x3070dd17;
    _h[6] = 0x152fecd8;
    _h[7] = 0xf70e5939;
    _h[8] = 0x67332667;
    _h[9] = 0xffc00b31;
    _h[10] = 0x8eb44a87;
    _h[11] = 0x68581511;
    _h[12] = 0xdb0c2e0d;
    _h[13] = 0x64f98fa7;
    _h[14] = 0x47b5481d;
    _h[15] = 0xbefa4fa4;
  }

  @override
  Uint8List _digest() {
    return _split32(_h.sublist(0, 12), endian);
  }
}
