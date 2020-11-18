import "dart:typed_data" show Uint8List;
import "package:convert/convert.dart" show hex;
import 'package:my_idena_wallet/util/helpers.dart';
import 'package:my_idena_wallet/util/idena_ffi/ffi/ed25519_blake2b.dart';
import "package:ethereum_address/ethereum_address.dart";

class IdenaAccounts {

  static bool isValid(String account) {
    assert(account != null);
    if (account == null) {
      return false;
    }
    // Returns whether a given Ethereum based address is valid.
    return isValidEthereumAddress(account);
  }

  static String extractPublicKey(String account) {
    /*assert(account != null);
    String encodedPublicKey = account;
    String binaryPublicKey = encoder.decode(encodedPublicKey).substring(4);
    String hexPublicKey =
        IdenaHelpers.binaryToHex(binaryPublicKey).padLeft(64, "0");
    return hexPublicKey;*/
    return "";
  }

  static String calculatedEncodedChecksum(String publicKey) {
    /*Uint8List checksum = IdenaHelpers.reverse(Ed25519Blake2b.accountChecksum(IdenaHelpers.hexToBytes(publicKey)));
    String binaryChecksum =
        IdenaHelpers.hexToBinary(IdenaHelpers.byteToHex(checksum))
            .padLeft(40, "0");
    return encoder.encode(binaryChecksum);*/
    return "";
  }
}
