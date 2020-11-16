import 'package:flutter/material.dart';

import 'package:my_idena_wallet/model/db/appdb.dart';
import 'package:my_idena_wallet/model/db/account.dart';
import 'package:my_idena_wallet/appstate_container.dart';
import 'package:my_idena_wallet/localization.dart';
import 'package:my_idena_wallet/service_locator.dart';
import 'package:my_idena_wallet/util/idena_ffi/account/account_util.dart';
import 'package:my_idena_wallet/util/idena_ffi/keys/keys.dart';

class IdenaUtil {

  static String seedToAddress(String seed, int index) { 
    print("seed: " + seed);
    String privateKey = IdenaKeys.seedToPrivate(seed, index);
    print("privateKey: " + privateKey);
    String pubKey = IdenaKeys.createPublicKey(privateKey);
    print("pubKey: " + pubKey);
    return IdenaAccounts.createAccount("028a8c59fa27d1e0f1643081ff80c3cf0392902acbf76ab0dc9c414b8d115b0ab3");
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
