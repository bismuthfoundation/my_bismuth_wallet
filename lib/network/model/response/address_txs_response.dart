// To parse this JSON data, do
//
//     final addressTxsResponse = addressTxsResponseFromJson(jsonString);

import 'package:my_bismuth_wallet/model/address.dart';
import 'package:my_bismuth_wallet/network/model/block_types.dart';
import 'package:my_bismuth_wallet/util/numberutil.dart';

class AddressTxsResponse {
  AddressTxsResponse({
    this.result,
  });

  List<AddressTxsResponseResult> result;
}

class AddressTxsResponseResult {
  AddressTxsResponseResult({
    this.blockHeight,
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
    this.hash
  });

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

  String getShortString() {
    return new Address(this.from).getShortString();
  }

  String getShorterString() {
    return new Address(this.from).getShorterString();
  }

  /*
   * Return amount formatted for use in the UI
   */
  String getFormattedAmount() {
    return NumberUtil.getRawAsUsableString(amount.toString());
  }

  void populate(List txs, String address) {
    blockHeight = txs[0];
    // TODO: pourquoi double ?
    
   // timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(txs[1]) * 1000);
    timestamp = DateTime.now();
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
    // TODO: a améliorer
    if (recipient == address) {
      type = BlockTypes.RECEIVE;
    } else {
      type = BlockTypes.SEND;
    }
  }
}
