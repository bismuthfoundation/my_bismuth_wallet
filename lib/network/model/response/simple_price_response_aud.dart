// To parse this JSON data, do
//
//     final simplePriceAudResponse = simplePriceAudResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceAudResponse simplePriceAudResponseFromJson(String str) => SimplePriceAudResponse.fromJson(json.decode(str));

String simplePriceaudResponseToJson(SimplePriceAudResponse data) => json.encode(data.toJson());

class SimplePriceAudResponse {
    SimplePriceAudResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceAudResponse.fromJson(Map<String, dynamic> json) => SimplePriceAudResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.aud,
    });

    double aud;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        aud: json["aud"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "aud": aud,
    };
}
