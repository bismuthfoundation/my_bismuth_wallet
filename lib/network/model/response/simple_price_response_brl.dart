// To parse this JSON data, do
//
//     final simplePriceBrlResponse = simplePriceBrlResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceBrlResponse simplePriceBrlResponseFromJson(String str) => SimplePriceBrlResponse.fromJson(json.decode(str));

String simplePriceBrlResponseToJson(SimplePriceBrlResponse data) => json.encode(data.toJson());

class SimplePriceBrlResponse {
    SimplePriceBrlResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceBrlResponse.fromJson(Map<String, dynamic> json) => SimplePriceBrlResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.brl,
    });

    double brl;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        brl: json["brl"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "brl": brl,
    };
}
