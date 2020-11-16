import 'dart:typed_data';

import 'package:my_idena_wallet/util/helpers.dart';
import 'package:my_idena_wallet/util/idena_ffi/ffi/ed25519_blake2b.dart';


class IdenaSignatures {
  static String signBlock(String hash, String privKey) {
    return IdenaHelpers.byteToHex(Ed25519Blake2b.signMessage(
        IdenaHelpers.hexToBytes(hash), IdenaHelpers.hexToBytes(privKey)));
  }

  static bool validateSig(String hash, Uint8List pubKey, Uint8List signature) {
    return Ed25519Blake2b.verifySignature(
        IdenaHelpers.hexToBytes(hash), pubKey, signature);
  }
}