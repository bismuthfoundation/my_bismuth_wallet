import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:hex/hex.dart';

class BismuthKeyDerivation {
  static String seedToAddress(String seed, int index) {
    final String mnemonic = bip39.entropyToMnemonic(seed);
    final Uint8List bip39Seed = bip39.mnemonicToSeed(mnemonic);
    final bip32.BIP32 rootKey = bip32.BIP32.fromSeed(bip39Seed);
    final bip32.BIP32 node = bip32.BIP32.fromBase58(rootKey.toBase58());
    final bip32.BIP32 addressDerived =
        node.derivePath("m/44'/209'/0'/0/$index");
    final Uint8List identifier = addressDerived.identifier!;

    final Uint8List buffer =
        Uint8List(identifier.length + 3);
    final ByteData bytes = buffer.buffer.asByteData();
    bytes.setUint8(0, 0x4f);
    bytes.setUint8(1, 0x54);
    bytes.setUint8(2, 0x5b);
    buffer.setRange(
      3,
      identifier.length + 3,
      identifier,
    );
    return bs58check.encode(buffer);
  }

  static Future<String> seedToPublicKeyBase64(String seed, int index) async {
    return base64.encode(
      bip32.BIP32.fromBase58(
        bip32.BIP32.fromSeed(
          bip39.mnemonicToSeed(bip39.entropyToMnemonic(seed)),
        ).toBase58(),
      ).derivePath("m/44'/209'/0'/0/$index").publicKey!,
    );
  }

  static Future<String> seedToPrivateKey(String seed, int index) async {
    return HEX.encode(
      bip32.BIP32.fromBase58(
        bip32.BIP32.fromSeed(
          bip39.mnemonicToSeed(bip39.entropyToMnemonic(seed)),
        ).toBase58(),
      ).derivePath("m/44'/209'/0'/0/$index").privateKey!,
    );
  }
}
