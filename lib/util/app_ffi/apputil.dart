
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
// Project imports:
import 'package:my_bismuth_wallet/appstate_container.dart';
import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/model/db/hiveDB.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/util/bismuth_key_derivation.dart';

class AppUtil {
  String seedToAddress(String seed, int index) {
    return BismuthKeyDerivation.seedToAddress(seed, index);
  }

  Future<String> seedToPublicKeyBase64(String seed, int index) async {
    return BismuthKeyDerivation.seedToPublicKeyBase64(seed, index);
  }

  Future<String> seedToPrivateKey(String seed, int index) async {
    return BismuthKeyDerivation.seedToPrivateKey(seed, index);
  }

  Future<void> loginAccount(String seed, BuildContext context) async {
    final Account selectedAcct = (await sl.get<DBHelper>().getSelectedAccount(seed))!;
    StateContainer.of(context).updateWallet(account: selectedAcct);
  }
}
