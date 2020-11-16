import "dart:typed_data" show Uint8List;
import "package:convert/convert.dart" show hex;
import 'package:my_idena_wallet/util/helpers.dart';
import 'package:my_idena_wallet/util/idena_ffi/account/account_coder.dart';
import 'package:my_idena_wallet/util/idena_ffi/ffi/ed25519_blake2b.dart';
import "package:ethereum_address/ethereum_address.dart";

class IdenaAccounts {
  static IdenaAccountEncodes encoder = IdenaAccountEncodes();

  static String createAccount(String publicKey) {
    /*String binaryPubkey = IdenaHelpers.hexToBinary(publicKey).padLeft(260, "0");
    String encodedChecksum = calculatedEncodedChecksum(publicKey);
    String encodedPubkey = encoder.encode(binaryPubkey);
    return encodedPubkey +
        encodedChecksum;
    */
    final bytesPubkey = hex.decode(publicKey);
    String address = ethereumAddressFromPublicKey(bytesPubkey);
    // Converts an Ethereum address to a checksummed address (EIP-55).
    String addressEIP55 = checksumEthereumAddress(address); 
    return "0xf2b4f700d2975abd39000587f9788f66afedf691";
  }

  static bool isValid(String account) {
    assert(account != null);
    if (account == null) {
      return false;
    }
    // Returns whether a given Ethereum based address is valid.
    return isValidEthereumAddress(account);
  }

  static String extractPublicKey(String account) {
    assert(account != null);
    String encodedPublicKey = account;
    String binaryPublicKey = encoder.decode(encodedPublicKey).substring(4);
    String hexPublicKey =
        IdenaHelpers.binaryToHex(binaryPublicKey).padLeft(64, "0");
    return hexPublicKey;
  }

  static String calculatedEncodedChecksum(String publicKey) {
    Uint8List checksum = IdenaHelpers.reverse(Ed25519Blake2b.accountChecksum(IdenaHelpers.hexToBytes(publicKey)));
    String binaryChecksum =
        IdenaHelpers.hexToBinary(IdenaHelpers.byteToHex(checksum))
            .padLeft(40, "0");
    return encoder.encode(binaryChecksum);
  }
}
