// To parse this JSON data, do
//
//     final addressTxsResponse = addressTxsResponseFromJson(jsonString);

import 'dart:convert';

import 'package:my_bismuth_wallet/model/address.dart';
import 'package:my_bismuth_wallet/util/numberutil.dart';

AddressTxsResponse addressTxsResponseFromJson(String str) =>
    AddressTxsResponse.fromJson(json.decode(str));

String addressTxsResponseToJson(AddressTxsResponse data) =>
    json.encode(data.toJson());

class AddressTxsResponse {
  AddressTxsResponse({
    this.result,
    this.continuationToken,
  });

  List<AddressTxsResponseResult> result;
  String continuationToken;

  factory AddressTxsResponse.fromJson(Map<String, dynamic> json) =>
      AddressTxsResponse(
        result: List<AddressTxsResponseResult>.from(
            json["result"].map((x) => AddressTxsResponseResult.fromJson(x))),
        continuationToken: json["continuationToken"],
      );

  Map<String, dynamic> toJson() => {
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
        "continuationToken": continuationToken,
      };
}

class AddressTxsResponseResult {
  AddressTxsResponseResult({
    this.hash,
    this.type,
    this.timestamp,
    this.from,
    this.amount,
    this.tips,
    this.maxFee,
    this.fee,
    this.size,
    this.data,
  });

  String hash;
  String type;
  DateTime timestamp;
  String from;
  String amount;
  String tips;
  String maxFee;
  String fee;
  int size;
  Data data;

  String getShortString() {
    return new Address(this.from).getShortString();
  }

  String getShorterString() {
    return new Address(this.from).getShorterString();
  }

  /**
   * Return amount formatted for use in the UI
   */
  String getFormattedAmount() {
    return NumberUtil.getRawAsUsableString(amount);
  }

  factory AddressTxsResponseResult.fromJson(Map<String, dynamic> json) =>
      AddressTxsResponseResult(
        hash: json["hash"],
        type: json["type"],
        timestamp: DateTime.parse(json["timestamp"]),
        from: json["from"],
        amount: json["amount"],
        tips: json["tips"],
        maxFee: json["maxFee"],
        fee: json["fee"],
        size: json["size"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "hash": hash,
        "type": type,
        "timestamp": timestamp.toIso8601String(),
        "from": from,
        "amount": amount,
        "tips": tips,
        "maxFee": maxFee,
        "fee": fee,
        "size": size,
        "data": data == null ? null : data.toJson(),
      };
}

class Data {
  Data({
    this.becomeOnline,
    this.dataBecomeOnline,
  });

  bool becomeOnline;
  bool dataBecomeOnline;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        becomeOnline: json["BecomeOnline"],
        dataBecomeOnline: json["becomeOnline"],
      );

  Map<String, dynamic> toJson() => {
        "BecomeOnline": becomeOnline,
        "becomeOnline": dataBecomeOnline,
      };
}
