part of hash;

class Hmac {
  BlockHash hash;
  late int blockSize;
  late int outSize;
  List<int>? _key;
  Hmac(this.hash, List<int> key) {
    blockSize = hash.blockSize ~/ 8;
    outSize = hash.outSize;
    _init(List<int>.from(key));
  }

  void _init(List<int> key) {
    /// Shorten key, if needed
    if (key.length > blockSize) {
      hash.reset();
      key = hash.update(key).digest();
    }
    assert(key.length <= blockSize);

    /// Add padding to key
    for (var i = key.length; i < blockSize; i++) {
      key.add(0);
    }

    for (var i = 0; i < key.length; i++) {
      key[i] ^= 0x36;
    }
    hash.reset();
    hash.update(key);

    for (var i = 0; i < key.length; i++) {
      key[i] ^= 0x6a;
    }
    _key = key;
  }

  void reset() {
    hash.reset();
  }

  Hmac update(List<int> msg) {
    hash.update(msg);
    return this;
  }

  Uint8List digest() {
    var ret = hash.digest();
    hash.reset();
    return hash.update(_key!).update(ret).digest();
  }
}
