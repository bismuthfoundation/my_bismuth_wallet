// To parse this JSON data, do
//
//     final simplePriceJpyResponse = simplePriceJpyResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceJpyResponse simplePriceJpyResponseFromJson(String str) => SimplePriceJpyResponse.fromJson(json.decode(str));

String simplePriceJpyResponseToJson(SimplePriceJpyResponse data) => json.encode(data.toJson());

class SimplePriceJpyResponse {
    SimplePriceJpyResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceJpyResponse.fromJson(Map<String, dynamic> json) => SimplePriceJpyResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.jpy,
    });

    double jpy;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        jpy: json["jpy"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "jpy": jpy,
    };
}
