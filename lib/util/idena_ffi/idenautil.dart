import 'dart:convert';

import 'package:ethereum_address/ethereum_address.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:sha3/sha3.dart';
import 'package:my_idena_wallet/model/db/appdb.dart';
import 'package:my_idena_wallet/model/db/account.dart';
import 'package:my_idena_wallet/appstate_container.dart';
import 'package:my_idena_wallet/localization.dart';
import 'package:my_idena_wallet/service_locator.dart';
import 'package:my_idena_wallet/util/hd_key.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:secp256k1/secp256k1.dart';
import 'package:quartet/quartet.dart';

class IdenaUtil {
  Future<String> seedToAddress(String seed, int index) async {
    print("seed: " + seed);

    //String privateKey = IdenaKeys.seedToPrivate(seed, index);
    //print("privateKey: " + privateKey);

    KeyData master = HDKey.getMasterKeyFromSeed(seed);
    String privateKey = HEX.encode(master.key);
    /*String privateKey =
        "771f43592e56eb3ee0cbb6e9d46b9c00eb196b9c1267e3829d04d11f1154c4f0a4ef1aebe47e71749c7cd1e9fc5a30fbbd2ec64251111154e416d4d0";
    print("privateKey: $privateKey");
    var pk = PrivateKey.fromHex(privateKey);
    var pub = pk.publicKey;
    print("pub: " + pub.toHex());
    print("pubComp: " + pub.toCompressedHex());

    
     const pubKey = ec
    .keyFromPrivate(key)
    .getPublic()
    .encode('array')
    return toHexString(sha3.keccak_256.array(pubKey.slice(1)).slice(12), true)
    
    var k = SHA3(256, KECCAK_PADDING, 256);
    k.update(utf8.encode(slice(pub.toCompressedHex(), 1)));
    var hash = k.digest();
    print("hash: " + HEX.encode(hash));
    print("hash slice12: " + slice(HEX.encode(hash), 12));
    
    */
    //String pubKey = IdenaKeys.createPublicKey(privateKey);
    //print("pubKey: " + pubKey);
    final ethPrivateKey = EthPrivateKey.fromHex(privateKey);
    final address = await ethPrivateKey.extractAddress();
    print("address: " + address.toString());

    String addressEIP55 = checksumEthereumAddress(address.toString());
    print("address EIP55: " + addressEIP55.toString());

    return address.toString();
  }

  Future<void> loginAccount(String seed, BuildContext context) async {
    Account selectedAcct = await sl.get<DBHelper>().getSelectedAccount(seed);
    if (selectedAcct == null) {
      selectedAcct = Account(
          index: 0,
          lastAccess: 0,
          name: AppLocalization.of(context).defaultAccountName,
          selected: true);
      await sl.get<DBHelper>().saveAccount(selectedAcct);
    }
    StateContainer.of(context).updateWallet(account: selectedAcct);
  }
}
