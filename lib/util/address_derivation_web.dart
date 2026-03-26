import 'package:my_bismuth_wallet/util/browser_ed25519_key_derivation_web.dart';

class AddressDerivationPlatform {
  static Future<String> seedToAddress(String seed, int index) {
    return BrowserEd25519KeyDerivation.seedToAddress(seed, index);
  }

  static Future<String> seedToPublicKeyBase64(String seed, int index) {
    return BrowserEd25519KeyDerivation.seedToPublicKeyBase64(seed, index);
  }

  static Future<String> seedToPrivateKey(String seed, int index) {
    return BrowserEd25519KeyDerivation.seedToPrivateKey(seed, index);
  }

  static Future<String> signBuffer({
    required String privateKeyHex,
    required String buffer,
  }) {
    return BrowserEd25519KeyDerivation.signBuffer(
      privateKeyHex: privateKeyHex,
      buffer: buffer,
    );
  }
}
