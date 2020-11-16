import 'package:my_idena_wallet/util/helpers.dart';
import 'package:my_idena_wallet/util/idena_ffi/ffi/ed25519_blake2b.dart';
import 'package:my_idena_wallet/util/idena_ffi/keys/seeds.dart';

class IdenaKeys {
  static String seedToPrivate(String seed, int index) {
    assert(IdenaSeeds.isValidSeed(seed));
    assert(index >= 0);
    return IdenaHelpers.byteToHex(
            Ed25519Blake2b.derivePrivkey(IdenaHelpers.hexToBytes(seed), index))
        .toUpperCase();
  }

  static String createPublicKey(String privateKey) {
    return IdenaHelpers.byteToHex(
        Ed25519Blake2b.getPubkey(IdenaHelpers.hexToBytes(privateKey)));
       
  }

}