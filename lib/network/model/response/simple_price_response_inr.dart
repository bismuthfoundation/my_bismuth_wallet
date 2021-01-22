// To parse this JSON data, do
//
//     final simplePriceInrResponse = simplePriceInrResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceInrResponse simplePriceInrResponseFromJson(String str) => SimplePriceInrResponse.fromJson(json.decode(str));

String simplePriceInrResponseToJson(SimplePriceInrResponse data) => json.encode(data.toJson());

class SimplePriceInrResponse {
    SimplePriceInrResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceInrResponse.fromJson(Map<String, dynamic> json) => SimplePriceInrResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.inr,
    });

    double inr;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        inr: json["inr"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "inr": inr,
    };
}
