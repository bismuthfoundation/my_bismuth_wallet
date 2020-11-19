import 'package:ethereum_address/ethereum_address.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';

import 'package:my_idena_wallet/model/db/appdb.dart';
import 'package:my_idena_wallet/model/db/account.dart';
import 'package:my_idena_wallet/appstate_container.dart';
import 'package:my_idena_wallet/localization.dart';
import 'package:my_idena_wallet/service/idena_service.dart';
import 'package:my_idena_wallet/service_locator.dart';
import 'package:my_idena_wallet/util/hd_key.dart';
import 'package:web3dart/web3dart.dart';

class IdenaUtil {

  Future<String> seedToAddress(String seed, int index) async { 


    print("seed: " + seed);
    
    //String privateKey = IdenaKeys.seedToPrivate(seed, index);
    //print("privateKey: " + privateKey);

    KeyData master = HDKey.getMasterKeyFromSeed(seed);
    final privateKey = HEX.encode(master.key);
    print("privateKey: $privateKey");

    //String pubKey = IdenaKeys.createPublicKey(privateKey);
    //print("pubKey: " + pubKey);

    final ethPrivateKey = EthPrivateKey.fromHex(privateKey);
    final address = await ethPrivateKey.extractAddress();
    print("address: " +address.toString());

    String addressEIP55 = checksumEthereumAddress(address.toString()); 
    print("address EIP55: " +addressEIP55.toString());

    return address.toString();
  }

  Future<void> loginAccount(String seed, BuildContext context) async {
    Account selectedAcct = await sl.get<DBHelper>().getSelectedAccount(seed);
    if (selectedAcct == null) { 
      selectedAcct = Account(index: 0, lastAccess: 0, name: AppLocalization.of(context).defaultAccountName, selected: true);
      await sl.get<DBHelper>().saveAccount(selectedAcct);
    }
    StateContainer.of(context).updateWallet(account: selectedAcct);
  }
}
