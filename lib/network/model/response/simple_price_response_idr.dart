// To parse this JSON data, do
//
//     final simplePriceIdrResponse = simplePriceIdrResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceIdrResponse simplePriceIdrResponseFromJson(String str) => SimplePriceIdrResponse.fromJson(json.decode(str));

String simplePriceIdrResponseToJson(SimplePriceIdrResponse data) => json.encode(data.toJson());

class SimplePriceIdrResponse {
    SimplePriceIdrResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceIdrResponse.fromJson(Map<String, dynamic> json) => SimplePriceIdrResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.idr,
    });

    double idr;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        idr: json["idr"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "idr": idr,
    };
}
