import 'package:my_bismuth_wallet/util/bismuth_key_derivation.dart';

class AddressDerivationPlatform {
  static Future<String> seedToAddress(String seed, int index) {
    return Future<String>.value(BismuthKeyDerivation.seedToAddress(seed, index));
  }

  static Future<String> seedToPublicKeyBase64(String seed, int index) {
    return BismuthKeyDerivation.seedToPublicKeyBase64(seed, index);
  }

  static Future<String> seedToPrivateKey(String seed, int index) {
    return BismuthKeyDerivation.seedToPrivateKey(seed, index);
  }

  static Future<String> signBuffer({
    required String privateKeyHex,
    required String buffer,
  }) {
    throw UnsupportedError('Web-only signing helper was called on a non-web platform.');
  }
}
