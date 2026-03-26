import 'package:my_bismuth_wallet/util/address_derivation_non_web.dart'
    if (dart.library.html) 'package:my_bismuth_wallet/util/address_derivation_web.dart'
    as address_derivation_platform;

class AddressDerivation {
  static Future<String> seedToAddress(String seed, int index) {
    return address_derivation_platform.AddressDerivationPlatform.seedToAddress(
      seed,
      index,
    );
  }

  static Future<String> seedToPublicKeyBase64(String seed, int index) {
    return address_derivation_platform
        .AddressDerivationPlatform.seedToPublicKeyBase64(seed, index);
  }

  static Future<String> seedToPrivateKey(String seed, int index) {
    return address_derivation_platform.AddressDerivationPlatform.seedToPrivateKey(
      seed,
      index,
    );
  }

  static Future<String> signBuffer({
    required String privateKeyHex,
    required String buffer,
  }) {
    return address_derivation_platform.AddressDerivationPlatform.signBuffer(
      privateKeyHex: privateKeyHex,
      buffer: buffer,
    );
  }
}
