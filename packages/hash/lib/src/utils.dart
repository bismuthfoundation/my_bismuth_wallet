part of hash;

const int _MASK_5 = 0x1F;
const int _MASK_32 = 0xFFFFFFFF;

final List<int> _MASK32_HI_BITS = [
  0xFFFFFFFF,
  0x7FFFFFFF,
  0x3FFFFFFF,
  0x1FFFFFFF,
  0x0FFFFFFF,
  0x07FFFFFF,
  0x03FFFFFF,
  0x01FFFFFF,
  0x00FFFFFF,
  0x007FFFFF,
  0x003FFFFF,
  0x001FFFFF,
  0x000FFFFF,
  0x0007FFFF,
  0x0003FFFF,
  0x0001FFFF,
  0x0000FFFF,
  0x00007FFF,
  0x00003FFF,
  0x00001FFF,
  0x00000FFF,
  0x000007FF,
  0x000003FF,
  0x000001FF,
  0x000000FF,
  0x0000007F,
  0x0000003F,
  0x0000001F,
  0x0000000F,
  0x00000007,
  0x00000003,
  0x00000001,
  0x00000000
];

/// Uint8List to Uint32List
List<int> _join32(List<int> msg, int start, int end, Endian endian) {
  var len = end - start;
  assert(len % 4 == 0);
  var res = List.filled((len ~/ 4), 0);
  for (var i = 0, k = start; i < res.length; i++, k += 4) {
    var w;
    if (endian == Endian.big) {
      w = (msg[k] << 24) | (msg[k + 1] << 16) | (msg[k + 2] << 8) | msg[k + 3];
    } else {
      w = (msg[k + 3] << 24) | (msg[k + 2] << 16) | (msg[k + 1] << 8) | msg[k];
    }
    res[i] = w;
  }
  return res;
}

/// Uint32List to Uint8List
Uint8List _split32(List<int> msg, Endian endian) {
  var res = ByteData(msg.length * 4);
  for (var i = 0, k = 0; i < msg.length; i++, k += 4) {
    var m = msg[i];
    res.setUint32(k, m, endian);
  }
  return res.buffer.asUint8List();
}

/// rot right uint32
int _rotr32(int x, int n) {
  return (x >> n) | ((_shiftl32(x, (32 - n))) & _MASK_32);
}

/// rot left uint32
int _rotl32(int x, int n) {
  return (_shiftl32(x, n)) | (x >> (32 - n) & _MASK_32);
}

/// shift left uint32
int _shiftl32(int x, int n) {
  n &= _MASK_5;
  x &= _MASK32_HI_BITS[n];
  return (x << n) & _MASK_32;
}

/// sum uint32
int _sum32(int a, [int b = 0, int c = 0, int d = 0, int e = 0]) {
  return (a + b + c + d + e) & _MASK_32;
}

/// ch32
int _ch32(int x, int y, int z) {
  return (x & y) ^ ((~x) & z) & _MASK_32;
}

/// maj32
int _maj32(int x, int y, int z) {
  return (x & y) ^ (x & z) ^ (y & z);
}

/// p32
int _p32(int x, int y, int z) {
  return x ^ y ^ z;
}

/// ft_1
int _ft_1(int s, int x, int y, int z) {
  if (s == 0) {
    return _ch32(x, y, z);
  }
  if (s == 1 || s == 3) {
    return _p32(x, y, z);
  }
  if (s == 2) {
    return _maj32(x, y, z);
  }
  return 0;
}

/// s0_256
int _s0_256(int x) {
  return _rotr32(x, 2) ^ _rotr32(x, 13) ^ _rotr32(x, 22);
}

/// s1_256
int _s1_256(int x) {
  return _rotr32(x, 6) ^ _rotr32(x, 11) ^ _rotr32(x, 25);
}

/// g0_256
int _g0_256(int x) {
  return _rotr32(x, 7) ^ _rotr32(x, 18) ^ (x >> 3 & _MASK_32);
}

/// g1_256
int _g1_256(int x) {
  return _rotr32(x, 17) ^ _rotr32(x, 19) ^ (x >> 10 & _MASK_32);
}

/// sum64
void _sum64(List<int> bytes, int pos, int ah, int al) {
  var bh = bytes[pos];
  var bl = bytes[pos + 1];

  var lo = _sum32(al, bl);
  var hi = (lo < al ? 1 : 0) + ah + bh;
  bytes[pos] = hi & _MASK_32;
  bytes[pos + 1] = lo;
}

/// sum64_hi
int _sum64_hi(int ah, int al, int bh, int bl) {
  var lo = _sum32(al, bl);
  var hi = (lo < al ? 1 : 0) + ah + bh;
  return hi & _MASK_32;
}

/// sum64_lo
int _sum64_lo(int ah, int al, int bh, int bl) {
  return _sum32(al, bl);
}

/// sum64_4_hi
int _sum64_4_hi(
    int ah, int al, int bh, int bl, int ch, int cl, int dh, int dl) {
  var carry = 0;
  var lo = al;
  lo = _sum32(lo, bl);
  carry += lo < al ? 1 : 0;
  lo = _sum32(lo, cl);
  carry += lo < cl ? 1 : 0;
  lo = _sum32(lo, dl);
  carry += lo < dl ? 1 : 0;

  var hi = ah + bh + ch + dh + carry;
  return hi & _MASK_32;
}

/// sum64_4_lo
int _sum64_4_lo(ah, al, bh, bl, ch, cl, dh, dl) {
  return _sum32(al, bl, cl, dl);
}

/// sum64_5_hi
int _sum64_5_hi(ah, al, bh, bl, ch, cl, dh, dl, eh, el) {
  var carry = 0;
  var lo = al;
  lo = _sum32(lo, bl);
  carry += lo < al ? 1 : 0;
  lo = _sum32(lo, cl);
  carry += lo < cl ? 1 : 0;
  lo = _sum32(lo, dl);
  carry += lo < dl ? 1 : 0;
  lo = _sum32(lo, el);
  carry += lo < el ? 1 : 0;

  var hi = ah + bh + ch + dh + eh + carry;
  return hi & _MASK_32;
}

/// sum64_5_lo
int _sum64_5_lo(int ah, int al, int bh, int bl, int ch, int cl, int dh, int dl,
    int eh, int el) {
  return _sum32(al, bl, cl, dl, el);
}

/// rotr64_hi
int _rotr64_hi(int ah, int al, int num) {
  var r = (al << (32 - num)) | (ah >> num & _MASK_32);
  return r & _MASK_32;
}

/// rotr64_lo
int _rotr64_lo(int ah, int al, int num) {
  var r = (_shiftl32(ah, (32 - num))) | (al >> num & _MASK_32);
  return r & _MASK_32;
}

/// shr64_hi
int _shr64_hi(int ah, int al, int num) {
  return ah >> num & _MASK_32;
}

/// shr64_lo
int _shr64_lo(int ah, int al, int num) {
  var r = (_shiftl32(ah, (32 - num))) | (al >> num & _MASK_32);
  return r & _MASK_32;
}
