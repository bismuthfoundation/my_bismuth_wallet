// To parse this JSON data, do
//
//     final simplePriceTwdResponse = simplePriceTwdResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceTwdResponse simplePriceTwdResponseFromJson(String str) => SimplePriceTwdResponse.fromJson(json.decode(str));

String simplePriceTwdResponseToJson(SimplePriceTwdResponse data) => json.encode(data.toJson());

class SimplePriceTwdResponse {
    SimplePriceTwdResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceTwdResponse.fromJson(Map<String, dynamic> json) => SimplePriceTwdResponse(
        bismuth: Bismuth.fromJson(json["bismuth"]),
    );

    Map<String, dynamic> toJson() => {
        "bismuth": bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.twd,
    });

    double twd;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        twd: json["twd"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "twd": twd,
    };
}
