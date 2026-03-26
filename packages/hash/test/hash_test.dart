import 'package:hash/hash.dart';
import 'package:test/test.dart';

/// hex encode
String encodeHEX(List<int> bytes) {
  var str = '';
  for (var i = 0; i < bytes.length; i++) {
    var s = bytes[i].toRadixString(16);

    str += s.padLeft(2, '0');
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
  var hashs = <String, BlockHash>{
    'md5': MD5(),
    'ripemd160': RIPEMD160(),
    'sha1': SHA1(),
    'sha224': SHA224(),
    'sha256': SHA256(),
    'sha384': SHA384(),
    'sha512': SHA512()
  };

  var valids = <String, List<String>>{
    'md5': <String>[
      '5fa6031211db79608db137d0a63d4a940208b103',
      '5b998007b69344e6acc6e8ff052e6d27',
      'message digest',
      'f96b697d7cb7938d525a2f31aaf161d0'
    ],
    'ripemd160': <String>[
      'abc',
      '8eb208f7e05d987a9b044a8e98c6b087f15a0bfc',
      'message digest',
      '5d0689ef49d2fae572b881b123a85ffa21595f36'
    ],
    'sha1': <String>['abc', 'a9993e364706816aba3e25717850c26c9cd0d89d'],
    'sha224': <String>[
      'abc',
      '23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7'
    ],
    'sha256': <String>[
      'abc',
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'
    ],
    'sha384': <String>[
      'abc',
      'cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7'
    ],
    'sha512': <String>[
      'abc',
      'ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f'
    ]
  };

  hashs.forEach((String type, BlockHash hash) {
    group('${type} encryption', () {
      var valid = valids[type];
      for (var i = 0; i < valid!.length; i += 2) {
        test('${type}: ${valid[i]}', () {
          hash.reset();
          var ret = hash.update(valid[i].codeUnits).digest();
          expect(valid[i + 1], encodeHEX(ret));
          expect(hash.outSize, ret.length);
        });
      }
    });
  });
}
