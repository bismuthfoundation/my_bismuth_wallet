import 'package:hash/hash.dart';

/// hex encode
String encodeHEX(List<int> bytes) {
  var str = '';
  for (var i = 0; i < bytes.length; i++) {
    var s = bytes[i].toRadixString(16);
    str += s.padLeft(2 - s.length, '0');
  }
  return str;
}

/// hex decode
List<int> decodeHEX(String hex) {
  var bytes = <int>[];
  var len = hex.length ~/ 2;
  for (var i = 0; i < len; i++) {
    bytes.add(int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16));
  }
  return bytes;
}

void main() {
  var hash = decodeHEX(
      '60bf6c46a8f6d9a02bb5a0f1f8691eb0d7d0cf649424f4d385bdf31fc261b4be');

  ///MD5
  var md5 = MD5();
  print(md5.update(hash).digest());

  /// => [157, 161, 39, 157, 129, 83, 38, 177, 20, 176, 28, 102, 71, 59, 161, 99]
  print(md5.outSize);

  /// => 16

  ///RIPEMD160
  var ripemd160 = RIPEMD160();
  print(ripemd160.update(hash).digest());

  /// => [106, 0, 130, 179, 127, 111, 174, 128, 101, 46, 44, 174, 206, 48, 221, 6, 84, 178, 249, 54]
  print(ripemd160.outSize);

  /// => 20

  ///sha1
  var sha1 = SHA1();
  print(sha1.update(hash).digest());

  /// => [89, 77, 139, 19, 242, 92, 237, 227, 192, 203, 65, 46, 162, 206, 69, 86, 38, 40, 133, 129]
  print(sha1.outSize);

  /// => 20

  ///sha2224
  var sha224 = SHA224();
  print(sha224.update(hash).digest());

  /// => [65, 21, 152, 248, 205, 84, 119, 117, 173, 117, 239, 216, 31, 240, 51, 11, 2, 74, 57, 0, 240, 120, 16, 202, 89, 114, 195, 156]
  print(sha224.outSize);

  /// => 28

  ///sha256
  var sha256 = SHA256();
  print(sha256.update(hash).digest());

  /// => [190, 194, 99, 8, 250, 99, 204, 92, 152, 27, 174, 217, 152, 110, 5, 15, 12, 18, 30, 166, 70, 222, 186, 8, 65, 188, 127, 150, 3, 103, 191, 161]
  print(sha256.outSize);

  /// => 32

  ///sha384
  var sha384 = SHA384();
  print(sha384.update(hash).digest());

  /// => [255, 109, 245, 134, 18, 229, 151, 64, 118, 141, 233, 133, 118, 18, 79, 238, 244, 54, 40, 231, 169, 89, 34, 186, 138, 82, 38, 3, 66, 242, 245, 157, 34, 29, 82, 79, 157, 0, 79, 1, 29, 128, 141, 105, 7, 123, 41, 240]
  print(sha384.outSize);

  /// => 48

  ///sha512
  var sha512 = SHA512();
  print(sha512.update(hash).digest());

  /// => [68, 17, 163, 18, 60, 62, 59, 176, 168, 3, 74, 33, 193, 202, 168, 157, 140, 188, 220, 213, 245, 97, 162, 84, 13, 178, 152, 188, 176, 243, 238, 209, 194, 238, 44, 11, 59, 100, 228, 19, 43, 181, 140, 127, 165, 69, 11, 206, 146, 129, 254, 203, 135, 91, 186, 104, 175, 145, 8, 155, 7, 184, 56, 56]
  print(sha512.outSize);

  /// => 64

  ///Hmac
  var hmac = Hmac(SHA256(), hash);
  print(hmac.update(hash).digest());

  /// => [13, 122, 158, 40, 212, 24, 185, 91, 221, 252, 165, 239, 33, 137, 147, 40, 112, 91, 216, 241, 221, 170, 60, 149, 60, 154, 67, 144, 6, 158, 65, 91]
  print(hmac.outSize);

  /// => 32
}
