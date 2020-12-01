// To parse this JSON data, do
//
//     final simplePriceAedResponse = simplePriceAedResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceAedResponse simplePriceAedResponseFromJson(String str) => SimplePriceAedResponse.fromJson(json.decode(str));

String simplePriceAedResponseToJson(SimplePriceAedResponse data) => json.encode(data.toJson());

class SimplePriceAedResponse {
    SimplePriceAedResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceAedResponse.fromJson(Map<String, dynamic> json) => SimplePriceAedResponse(
        bismuth: Bismuth.fromJson(json["bismuth"]),
    );

    Map<String, dynamic> toJson() => {
        "bismuth": bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.aed,
    });

    double aed;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        aed: json["aed"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "aed": aed,
    };
}
