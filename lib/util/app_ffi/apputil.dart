import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:ethereum_address/ethereum_address.dart';
import 'package:flutter/material.dart';
import 'package:hash/hash.dart';
import 'package:hex/hex.dart';
import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/model/db/account.dart' as Account;
import 'package:my_bismuth_wallet/appstate_container.dart';
import 'package:my_bismuth_wallet/localization.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/service/app_service.dart';
import 'package:my_bismuth_wallet/util/app_ffi/crypto/sha.dart';
import 'package:my_bismuth_wallet/util/helpers.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:web3dart/web3dart.dart';
import 'package:crypto/crypto.dart';
import 'package:bs58check/bs58check.dart' as bs58check;

class AppUtil {

  String getAddress(node, [network]) {
  return P2PKH(data: new PaymentData(pubkey: node.publicKey), network: network)
      .data
      .address;
}

  Future<String> seedToAddress(String seed, int index) async {
    
    String mnemonic = bip39.entropyToMnemonic(seed);
    print("Mnemonic : " + mnemonic);
    final bip39Seed = bip39.mnemonicToSeed(mnemonic);
    print("BIP 39 Seed : " + HEX.encode(bip39Seed));

    final root = bip32.BIP32.fromSeed(bip39Seed);
    print("BIP 32 Root Key : " + root.toBase58());
    bip32.BIP32 node = bip32.BIP32.fromBase58(root.toBase58());
    print("BIP 32 node (private Key) : " + HEX.encode(node.privateKey));
    print("BIP 32 node (public Key) : " + HEX.encode(node.publicKey));
    bip32.BIP32 child = node.derivePath("m/44'/209'/0'/0");
    print("BIP 32 Extended private Key : " + child.toBase58());
    bip32.BIP32 childNeutered = child.neutered();
    print("BIP 32 Extended public Key : " + childNeutered.toBase58());

    print("BIP 32 child (private Key) : " + HEX.encode(child.privateKey));
    print("BIP 32 child (public Key) : " + HEX.encode(child.publicKey));

    bip32.BIP32 addressDerived0 = child.derive(0);
    print("Public Key Derived Address (account 0) : " + HEX.encode(addressDerived0.publicKey));
    print("Private Key Derived Address (account 0) : " + HEX.encode(addressDerived0.privateKey));
    print("Private Key Wif : " + addressDerived0.toWIF());

    var bytes1 = utf8.encode(HEX.encode(addressDerived0.publicKey));  
    var sha256 = SHA256();
    var hashSha256 = sha256.update(bytes1).digest();
    print("Public Key (SHA256) : " + HEX.encode(hashSha256));
    var ripemd160 = RIPEMD160();
    var hashRipemd160 = ripemd160.update(hashSha256).digest();
    print("Public Key (RIPEMD160) : " + HEX.encode(hashRipemd160));
    var hashRipemd160WithPrefix = ("0x4f545b" + HEX.encode(hashRipemd160));
    /*Uint8List addressUint8List;
    addressUint8List.add(AppHelpers.hexToBytes("4f"));
    addressUint8List.add(0x54);
    addressUint8List.add(0x5b);
    addressUint8List.addAll(hashRipemd160);
    print("Address : " + HEX.encode(addressUint8List));*/

    String address = bs58check.encode(hashRipemd160);
    print("Address (BS58Checksum) : " + address);

    AppService appService = new AppService();
    appService.testRpcConnection();

    return HEX.encode(hashRipemd160);
  }

  Future<void> loginAccount(String seed, BuildContext context) async {
    Account.Account selectedAcct =
        await sl.get<DBHelper>().getSelectedAccount(seed);
    if (selectedAcct == null) {
      selectedAcct = Account.Account(
          index: 0,
          lastAccess: 0,
          name: AppLocalization.of(context).defaultAccountName,
          selected: true);
      await sl.get<DBHelper>().saveAccount(selectedAcct);
    }
    StateContainer.of(context).updateWallet(account: selectedAcct);
  }
}
