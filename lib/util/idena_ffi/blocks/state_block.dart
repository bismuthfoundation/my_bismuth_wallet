import 'dart:typed_data';
import 'package:my_idena_wallet/util/helpers.dart';
import 'package:my_idena_wallet/util/idena_ffi/account/account_util.dart';
import 'package:my_idena_wallet/util/idena_ffi/ffi/ed25519_blake2b.dart';


class IdenaBlocks {
  static String computeStateHash(String account,
      String previous, String representative, BigInt balance, String link) {
    Uint8List accountBytes =
        IdenaHelpers.hexToBytes(IdenaAccounts.extractPublicKey(account));
    Uint8List previousBytes = IdenaHelpers.hexToBytes(previous.padLeft(64, "0"));
    Uint8List representativeBytes =
        IdenaHelpers.hexToBytes(IdenaAccounts.extractPublicKey(representative));
    Uint8List balanceBytes = IdenaHelpers.bigIntToBytes(balance);
    Uint8List linkBytes = IdenaAccounts.isValid(link)
        ? IdenaHelpers.hexToBytes(IdenaAccounts.extractPublicKey(link))
        : IdenaHelpers.hexToBytes(link);
    return IdenaHelpers.byteToHex(
      Ed25519Blake2b.computeHash(accountBytes, previousBytes, representativeBytes, balanceBytes, linkBytes)
    );
  }
}