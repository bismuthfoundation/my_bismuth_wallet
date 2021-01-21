// To parse this JSON data, do
//
//     final addressTxsResponse = addressTxsResponseFromJson(jsonString);

import 'package:my_bismuth_wallet/model/address.dart';
import 'package:my_bismuth_wallet/network/model/block_types.dart';
import 'package:my_bismuth_wallet/util/numberutil.dart';

class AddressTxsResponse {
  AddressTxsResponse({
    this.result,
    this.tokens
  });

  List<AddressTxsResponseResult> result;
  List<BisToken> tokens;
}

class BisToken {
  BisToken({this.tokenName, this.tokensQuantity, this.tokenMessage});
  String tokenName;
  int tokensQuantity;
  String tokenMessage;
}

class AddressTxsResponseResult {
  AddressTxsResponseResult(
      {this.blockHeight,
      this.timestamp,
      this.from,
      this.recipient,
      this.amount,
      this.signature,
      this.publicKey,
      this.blockHash,
      this.fee,
      this.reward,
      this.operation,
      this.openfield,
      this.type,
      this.hash});

  int blockHeight;
  DateTime timestamp;
  String from;
  String recipient;
  String amount;
  String signature;
  String publicKey;
  String blockHash;
  double fee;
  int reward;
  String operation;
  String openfield;
  String type;
  String hash;

  static const String TOKEN_TRANSFER = "token:transfer";
  static const String ALIAS_REGISTER = "alias:register";
  

  String getShortString() {
    if (type == BlockTypes.RECEIVE) {
      return new Address(this.from).getShortString();
    } else {
      return new Address(this.recipient).getShortString();
    }
  }

  String getShorterString() {
    if (type == BlockTypes.RECEIVE) {
      return new Address(this.from).getShorterString();
    } else {
      return new Address(this.recipient).getShorterString();
    }
  }

  /*
   * Return amount formatted for use in the UI
   */
  String getFormattedAmount() {
    return NumberUtil.getRawAsUsableString(amount.toString());
  }

  bool isTokenTransfer() {
    bool isTokenTransfer;
    operation == TOKEN_TRANSFER
        ? isTokenTransfer = true
        : isTokenTransfer = false;
    return isTokenTransfer;
  }

  bool isAliasRegister() {
    bool isAliasRegister;
    operation == ALIAS_REGISTER
        ? isAliasRegister = true
        : isAliasRegister = false;
    return isAliasRegister;
  }

  BisToken getBisToken() {
    BisToken bisToken;
    if (isTokenTransfer()) {
      bisToken = new BisToken(
          tokenName: openfield.split(":")[0],
          tokensQuantity: int.tryParse(openfield.split(":")[1]),
          tokenMessage: openfield.split(":").length < 3
              ? ""
              : openfield
                  .split(":")[3]
                  .replaceAll(RegExp('"'), '')
                  .replaceAll(RegExp('}'), ''));
    }
    return bisToken;
  }

  void populate(List txs, String address) {
    blockHeight = txs[0];
    timestamp = DateTime.fromMillisecondsSinceEpoch((txs[1] * 1000).toInt());
    from = txs[2];
    recipient = txs[3];
    amount = txs[4].toString();
    signature = txs[5];
    hash = signature.length > 56 ? signature.substring(0, 55) : signature;
    publicKey = txs[6];
    blockHash = txs[7];
    fee = txs[8];
    reward = txs[9];
    operation = txs[10];
    openfield = txs[11];
    if (recipient == address) {
      type = BlockTypes.RECEIVE;
    } else {
      type = BlockTypes.SEND;
    }
  }
}
