// To parse this JSON data, do
//
//     final simplePriceGbpResponse = simplePriceGbpResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceGbpResponse simplePriceGbpResponseFromJson(String str) => SimplePriceGbpResponse.fromJson(json.decode(str));

String simplePriceGbpResponseToJson(SimplePriceGbpResponse data) => json.encode(data.toJson());

class SimplePriceGbpResponse {
    SimplePriceGbpResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceGbpResponse.fromJson(Map<String, dynamic> json) => SimplePriceGbpResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.gbp,
    });

    double gbp;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        gbp: json["gbp"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "gbp": gbp,
    };
}
