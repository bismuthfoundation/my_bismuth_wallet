// @dart=2.9

import 'dart:convert';

import 'package:hash/hash.dart';
import 'package:hex/hex.dart';
import 'package:my_bismuth_wallet/model/address.dart';
import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/model/db/contact.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/util/base_85_decode.dart';

class BisUrl {
  String contactName;
  String address;
  String amount;
  String operation;
  String openfield;
  String comment;
  bool isTokenToSend;
  int tokenToSendQty;
  String tokenName;

  BisUrl(
      {this.contactName,
      this.address,
      this.amount,
      this.operation,
      this.openfield,
      this.comment,
      this.isTokenToSend,
      this.tokenName,
      this.tokenToSendQty});

  Future<BisUrl> getInfo(String link) async {
    BisUrl _bisUrl = new BisUrl();
    bool bisUrlLegacy = true;
    String checksum;
    //print("link: " + link);
    if (link.contains("bis://pay/") == true) {
      link = link.replaceAll("bis://pay/", "");
    } else {
      bisUrlLegacy = false;
      link = link.replaceAll("bis://", "");
    }
    List<String> paramBisUrl = link.split("/");
    Address address;
    Contact contact;

    if (bisUrlLegacy == false) {
      // New format url based b64urlsafe
      if (paramBisUrl.length > 0) {
        address = Address(paramBisUrl[0]);
      }
      if (paramBisUrl.length > 1) {
        amount = paramBisUrl[1];
      }
      if (paramBisUrl.length > 2) {
        operation = String.fromCharCodes(base64Url.decode(paramBisUrl[2]));
      }
      if (paramBisUrl.length > 3) {
        openfield = String.fromCharCodes(base64Url.decode(paramBisUrl[3]));
      }
      if (paramBisUrl.length > 4) {
        checksum = HEX.encode(base64Url.decode(paramBisUrl[4]));
        /* print("check fourni : " + checksum);
        String url = "bis://" +
            paramBisUrl[0] +
            "/" +
            paramBisUrl[1] +
            "/" +
            paramBisUrl[2] +
            "/" +
            paramBisUrl[3];
        print("check url : " + HEX.encode(Blake2bHash.hashWithDigestSize(4, base64Url.decode(paramBisUrl[4]))));*/

      }
    } else {
      // Old format url based base85
      if (paramBisUrl.length > 0) {
        address = Address(paramBisUrl[0]);
      }
      if (paramBisUrl.length > 1) {
        amount = paramBisUrl[1];
      }
      if (paramBisUrl.length > 2) {
        operation = Base85Decode().decode(paramBisUrl[2]);
      }
      if (paramBisUrl.length > 3) {
        openfield = Base85Decode().decode(paramBisUrl[3]);
      }
      if (paramBisUrl.length > 4) {
        var md5 = MD5();
        var hashMD5 = md5.update(utf8.encode(paramBisUrl[4])).digest();
        //print("hashMD5 : " + Base85Decode().decode(HEX.encode(hashMD5)));
        /*print("checksumMD5 : " +
            Base85Decode().encode("bis://pay/" +
                address.address +
                "/" +
                amount +
                "/" +
                operation +
                "/" +
                openfield));*/
      }
    }
    if (address != null &&
        address.address != null &&
        address.address.length > 0) {
      // See if a contact
      contact = await sl.get<DBHelper>().getContactWithAddress(address.address);
      if (contact != null) {
        contactName = contact.name;
      }
    }

    //print("amount : " + amount);
    //print("operation : " + operation);
    //print("openfield : " + openfield);
    isTokenToSend = false;
    if (operation == AddressTxsResponseResult.TOKEN_TRANSFER) {
      isTokenToSend = true;
      List<String> openfieldSplit = openfield.split(":");
      if (openfieldSplit.length > 0 && openfieldSplit[0].length > 0) {
        tokenName = openfieldSplit[0];
      }
      if (openfieldSplit.length > 1 && openfieldSplit[1].length > 0) {
        tokenToSendQty = int.tryParse(openfieldSplit[1]);
      }
      if (openfieldSplit.length > 3 && openfieldSplit[3].length > 1) {
        comment = openfieldSplit[3]
            .substring(0, openfieldSplit[3].length - 1)
            .replaceAll('"', '');
      }
    }
    if (address != null &&
        address.address != null &&
        address.address.length > 0) {
      _bisUrl.address = address.address;
    } else {
      _bisUrl.address = "";
    }

    _bisUrl.isTokenToSend = isTokenToSend;
    _bisUrl.tokenToSendQty = tokenToSendQty == null ? 0 : tokenToSendQty;
    _bisUrl.amount = amount == null ? "0" : amount;
    _bisUrl.openfield = openfield == null ? "" : openfield;
    _bisUrl.comment = comment == null ? "" : comment;
    _bisUrl.contactName = contactName == null ? "" : contactName;
    _bisUrl.operation = operation == null ? "" : operation;
    _bisUrl.tokenName = tokenName == null ? "" : tokenName;
    return _bisUrl;
  }
}
