part of hash;

/// An interface for cryptographic hash functions.
class BlockHash {
  late List<int>? pending;
  int pendingTotal = 0;
  late int blockSize;
  late int padLength;
  late int outSize;
  Endian endian = Endian.big;

  late int _delta8;
  late int _delta32;
  BlockHash() {
    padLength = padLength ~/ 8;
    _delta8 = blockSize ~/ 8;
    _delta32 = blockSize ~/ 32;
    reset();
  }

  /// reset
  void reset() {
    pendingTotal = 0;
    pending = null;
  }

  void _update(List<int> msg, int start) {}

  /// add data
  BlockHash update(List<int> msg) {
    /// Convert message to array, pad it, and join into 32bit blocks
    if (pending?.isEmpty ?? true) {
      pending = List.from(msg);
    } else {
      pending!.addAll(msg);
    }
    pendingTotal += msg.length;

    /// Enough data, try updating
    if (pending!.length >= _delta8) {
      msg = pending!;

      /// Process pending data in blocks
      var r = msg.length % _delta8;
      pending = msg.sublist(msg.length - r, msg.length);
      if (pending?.isEmpty ?? true) {
        pending = null;
      }
      msg = _join32(msg, 0, msg.length - r, endian);
      for (var i = 0; i < msg.length; i += _delta32) {
        _update(msg, i);
      }
    }

    return this;
  }

  /// pad data
  Uint8List _pad() {
    var len = pendingTotal;
    var k = _delta8 - ((len + padLength) % _delta8);
    var res = ByteData(k + padLength);
    res.setUint8(0, 0x80);
    var i;
    for (i = 1; i < k; i++) {
      res.setUint8(i, 0);
    }

    /// Append length
    len <<= 3;
    if (endian == Endian.big) {
      for (var t = 8; t < padLength; t++) {
        res.setUint8(i++, 0);
      }
      res.setUint32(i, 0);
      i += 4;
      res.setUint32(i, len);
      i += 4;
    } else {
      res.setUint32(i, len, Endian.little);
      i += 4;
      res.setUint32(i, 0);

      for (var t = 8; t < padLength; t++) {
        res.setUint8(i++, 0);
      }
    }

    return res.buffer.asUint8List();
  }

  Uint8List _digest() {
    return Uint8List(0);
  }

  Uint8List digest() {
    update(_pad());

    assert(pending == null);

    return _digest();
  }
}
