// To parse this JSON data, do
//
//     final simplePriceMyrResponse = simplePriceMyrResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceMyrResponse simplePriceMyrResponseFromJson(String str) => SimplePriceMyrResponse.fromJson(json.decode(str));

String simplePriceMyrResponseToJson(SimplePriceMyrResponse data) => json.encode(data.toJson());

class SimplePriceMyrResponse {
    SimplePriceMyrResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceMyrResponse.fromJson(Map<String, dynamic> json) => SimplePriceMyrResponse(
        bismuth: Bismuth.fromJson(json["bismuth"]),
    );

    Map<String, dynamic> toJson() => {
        "bismuth": bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.myr,
    });

    double myr;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        myr: json["myr"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "myr": myr,
    };
}
