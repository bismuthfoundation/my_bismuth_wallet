// To parse this JSON data, do
//
//     final addressResponse = addressResponseFromJson(jsonString);

import 'dart:convert';

AddressResponse addressResponseFromJson(String str) => AddressResponse.fromJson(json.decode(str));

String addressResponseToJson(AddressResponse data) => json.encode(data.toJson());

class AddressResponse {
    AddressResponse({
        this.result,
    });

    Result result;

    factory AddressResponse.fromJson(Map<String, dynamic> json) => AddressResponse(
        result: Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "result": result.toJson(),
    };
}

class Result {
    Result({
        this.address,
        this.balance,
        this.stake,
        this.txCount,
        this.flipsCount,
        this.reportedFlipsCount,
    });

    String address;
    String balance;
    String stake;
    int txCount;
    int flipsCount;
    int reportedFlipsCount;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        address: json["address"],
        balance: json["balance"],
        stake: json["stake"],
        txCount: json["txCount"],
        flipsCount: json["flipsCount"],
        reportedFlipsCount: json["reportedFlipsCount"],
    );

    Map<String, dynamic> toJson() => {
        "address": address,
        "balance": balance,
        "stake": stake,
        "txCount": txCount,
        "flipsCount": flipsCount,
        "reportedFlipsCount": reportedFlipsCount,
    };
}
