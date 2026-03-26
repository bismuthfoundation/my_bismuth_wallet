import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:hash/hash.dart';
import 'package:web/web.dart' as web;

class BrowserEd25519KeyDerivation {
  static const List<int> _ed25519AddressVersion = <int>[0x03, 0xB8, 0x6C, 0xF3];
  static const List<int> _derivationPath = <int>[44, 209, 0, 0];
  static const String _base58Alphabet =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  static Future<String> seedToAddress(String seed, int index) async {
    final Uint8List publicKey = await _derivePublicKeyBytes(seed, index);
    final Uint8List base = Uint8List(_ed25519AddressVersion.length + publicKey.length)
      ..setRange(0, _ed25519AddressVersion.length, _ed25519AddressVersion)
      ..setRange(_ed25519AddressVersion.length, _ed25519AddressVersion.length + publicKey.length, publicKey);
    final Uint8List checksum = SHA256().update(base).digest().sublist(0, 4);
    final Uint8List addressBytes = Uint8List(base.length + checksum.length)
      ..setRange(0, base.length, base)
      ..setRange(base.length, base.length + checksum.length, checksum);
    return _base58Encode(addressBytes);
  }

  static Future<String> seedToPublicKeyBase64(String seed, int index) async {
    final Uint8List publicKey = await _derivePublicKeyBytes(seed, index);
    return base64.encode(publicKey);
  }

  static Future<String> seedToPrivateKey(String seed, int index) async {
    return hex.encode(_derivePrivateKeySeed(seed, index));
  }

  static Future<String> signBuffer({
    required String privateKeyHex,
    required String buffer,
  }) async {
    final Uint8List privateKeySeed = _normalizePrivateKeySeed(hex.decode(privateKeyHex));
    final web.CryptoKey privateKey = await _importPrivateKey(privateKeySeed);
    final JSAny? signature = await web.window.crypto.subtle
        .sign(
          web.Algorithm(name: 'Ed25519'),
          privateKey,
          Uint8List.fromList(utf8.encode(buffer)).toJS,
        )
        .toDart;
    final ByteBuffer signatureBuffer = (signature! as JSArrayBuffer).toDart;
    return base64.encode(Uint8List.view(signatureBuffer));
  }

  static Uint8List _derivePrivateKeySeed(String seed, int index) {
    final String mnemonic = bip39.entropyToMnemonic(seed);
    final Uint8List bip39Seed = bip39.mnemonicToSeed(mnemonic);

    Uint8List digest =
        Hmac(SHA512(), Uint8List.fromList(utf8.encode('ed25519 seed')))
            .update(bip39Seed)
            .digest();
    Uint8List key = Uint8List.fromList(digest.sublist(0, 32));
    Uint8List chainCode = Uint8List.fromList(digest.sublist(32, 64));

    for (final int segment in <int>[..._derivationPath, index]) {
      final Uint8List data = Uint8List(1 + key.length + 4)
        ..[0] = 0
        ..setRange(1, 1 + key.length, key)
        ..setRange(1 + key.length, 1 + key.length + 4, _serializeHardenedIndex(segment));
      digest = Hmac(SHA512(), chainCode).update(data).digest();
      key = Uint8List.fromList(digest.sublist(0, 32));
      chainCode = Uint8List.fromList(digest.sublist(32, 64));
    }

    return key;
  }

  static Future<Uint8List> _derivePublicKeyBytes(String seed, int index) async {
    final Uint8List privateKeySeed = _derivePrivateKeySeed(seed, index);
    final web.CryptoKey privateKey = await _importPrivateKey(privateKeySeed);
    final JSAny? exported = await web.window.crypto.subtle.exportKey('jwk', privateKey).toDart;
    final JSObject jwk = exported! as JSObject;
    final JSString? xValue = jwk['x'] as JSString?;
    if (xValue == null) {
      throw StateError('Could not export the Ed25519 public key.');
    }
    return Uint8List.fromList(
      base64Url.decode(base64Url.normalize(xValue.toDart)),
    );
  }

  static Future<web.CryptoKey> _importPrivateKey(Uint8List privateKeySeed) {
    return web.window.crypto.subtle
        .importKey(
          'pkcs8',
          _pkcs8FromSeed(privateKeySeed).toJS,
          web.Algorithm(name: 'Ed25519'),
          true,
          <JSString>['sign'.toJS].toJS,
        )
        .toDart;
  }

  static Uint8List _serializeHardenedIndex(int index) {
    final ByteData data = ByteData(4);
    data.setUint32(0, index | 0x80000000, Endian.big);
    return data.buffer.asUint8List();
  }

  static Uint8List _normalizePrivateKeySeed(List<int> privateKeyBytes) {
    if (privateKeyBytes.length == 32) {
      return Uint8List.fromList(privateKeyBytes);
    }
    if (privateKeyBytes.length == 64) {
      return Uint8List.fromList(privateKeyBytes.sublist(0, 32));
    }
    throw ArgumentError('Expected a 32-byte Ed25519 private key seed.');
  }

  static Uint8List _pkcs8FromSeed(Uint8List seed) {
    final Uint8List pkcs8 = Uint8List(16 + seed.length);
    const List<int> prefix = <int>[
      0x30, 0x2E, 0x02, 0x01, 0x00, 0x30, 0x05, 0x06,
      0x03, 0x2B, 0x65, 0x70, 0x04, 0x22, 0x04, 0x20,
    ];
    pkcs8.setRange(0, prefix.length, prefix);
    pkcs8.setRange(prefix.length, prefix.length + seed.length, seed);
    return pkcs8;
  }

  static String _base58Encode(Uint8List source) {
    if (source.isEmpty) {
      return '';
    }

    final List<int> digits = <int>[0];
    for (final int byte in source) {
      int carry = byte;
      for (int j = 0; j < digits.length; j++) {
        carry += digits[j] << 8;
        digits[j] = carry % _base58Alphabet.length;
        carry ~/= _base58Alphabet.length;
      }
      while (carry > 0) {
        digits.add(carry % _base58Alphabet.length);
        carry ~/= _base58Alphabet.length;
      }
    }

    final StringBuffer output = StringBuffer();
    for (int i = 0; i < source.length - 1 && source[i] == 0; i++) {
      output.write(_base58Alphabet[0]);
    }
    for (int i = digits.length - 1; i >= 0; i--) {
      output.write(_base58Alphabet[digits[i]]);
    }
    return output.toString();
  }
}
