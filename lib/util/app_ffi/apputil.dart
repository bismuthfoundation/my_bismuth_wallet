import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:ethereum_address/ethereum_address.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/model/db/account.dart' as Account;
import 'package:my_bismuth_wallet/appstate_container.dart';
import 'package:my_bismuth_wallet/localization.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:web3dart/web3dart.dart';

class AppUtil {
  Future<String> seedToAddress(String seed, int index) async {
    
    String mnemonic = bip39.entropyToMnemonic(seed);

    final bip39Seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(bip39Seed);
    bip32.BIP32 node = bip32.BIP32.fromBase58(root.toBase58());
    print("BIP 32 node (private Key) : " + HEX.encode(node.privateKey));
    print("BIP 32 node (public Key) : " + HEX.encode(node.publicKey));
    bip32.BIP32 child = node.derivePath("m/44'/209'/0'/0");
    print("BIP 32 child (private Key) : " + HEX.encode(child.privateKey));
    print("BIP 32 child (public Key) : " + HEX.encode(child.publicKey));

    /*EthPrivateKey ethPrivateKey;
    String addressEIP55;
    // TODO: Distinct new address and regeneration of known address
    for(int numAddress = 0; numAddress < 10; numAddress ++)
   {
      ethPrivateKey =
          EthPrivateKey.fromHex(HEX.encode(child.derive(numAddress).privateKey));
      final address0 = await ethPrivateKey.extractAddress();
      addressEIP55 = checksumEthereumAddress(address0.toString());
      //print("address EIP55 ("+numAddress.toString()+"): " + addressEIP55.toString());
      AddressResponse addressResponse =
        await AppService().getAddressResponse(addressEIP55);
        if (addressResponse.result == null) {
          break;
        }
    }*/
     /*ethPrivateKey =
          EthPrivateKey.fromHex(HEX.encode(child.derive(0).privateKey));
      final address = await ethPrivateKey.extractAddress();
      addressEIP55 = checksumEthereumAddress(address.toString());
      //print("address EIP55 ("+numAddress.toString()+"): " + addressEIP55.toString());
*/
    return HEX.encode(child.publicKey);
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
