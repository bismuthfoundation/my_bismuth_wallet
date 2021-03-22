// To parse this JSON data, do
//
//     final simplePriceKwdResponse = simplePriceKwdResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceKwdResponse simplePriceKwdResponseFromJson(String str) => SimplePriceKwdResponse.fromJson(json.decode(str));

String simplePriceKwdResponseToJson(SimplePriceKwdResponse data) => json.encode(data.toJson());

class SimplePriceKwdResponse {
    SimplePriceKwdResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceKwdResponse.fromJson(Map<String, dynamic> json) => SimplePriceKwdResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.kwd,
    });

    double kwd;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        kwd: json["kwd"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "kwd": kwd,
    };
}
