// To parse this JSON data, do
//
//     final simplePriceKrwResponse = simplePriceKrwResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceKrwResponse simplePriceKrwResponseFromJson(String str) => SimplePriceKrwResponse.fromJson(json.decode(str));

String simplePriceKrwResponseToJson(SimplePriceKrwResponse data) => json.encode(data.toJson());

class SimplePriceKrwResponse {
    SimplePriceKrwResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceKrwResponse.fromJson(Map<String, dynamic> json) => SimplePriceKrwResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.krw,
    });

    double krw;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        krw: json["krw"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "krw": krw,
    };
}
