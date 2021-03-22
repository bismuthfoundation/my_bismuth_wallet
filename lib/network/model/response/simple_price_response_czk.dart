// To parse this JSON data, do
//
//     final simplePriceCzkResponse = simplePriceCzkResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceCzkResponse simplePriceCzkResponseFromJson(String str) => SimplePriceCzkResponse.fromJson(json.decode(str));

String simplePriceCzkResponseToJson(SimplePriceCzkResponse data) => json.encode(data.toJson());

class SimplePriceCzkResponse {
    SimplePriceCzkResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceCzkResponse.fromJson(Map<String, dynamic> json) => SimplePriceCzkResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.czk,
    });

    double czk;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        czk: json["czk"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "czk": czk,
    };
}
