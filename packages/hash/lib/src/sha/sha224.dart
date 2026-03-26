part of hash;

/// An instance of [SHA224].
class SHA224 extends SHA256 {
  @override
  int blockSize = 512;
  @override
  int padLength = 64;
  @override
  int outSize = 28;
  @override
  final List<int> _h = List.filled(8, 0);

  @override
  void reset() {
    super.reset();
    _h[0] = 0xc1059ed8;
    _h[1] = 0x367cd507;
    _h[2] = 0x3070dd17;
    _h[3] = 0xf70e5939;
    _h[4] = 0xffc00b31;
    _h[5] = 0x68581511;
    _h[6] = 0x64f98fa7;
    _h[7] = 0xbefa4fa4;
  }

  @override
  Uint8List _digest() {
    return _split32(_h.sublist(0, 7), endian);
  }
}
