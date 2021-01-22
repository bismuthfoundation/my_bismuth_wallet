// To parse this JSON data, do
//
//     final simplePriceHkdResponse = simplePriceHkdResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceHkdResponse simplePriceHkdResponseFromJson(String str) => SimplePriceHkdResponse.fromJson(json.decode(str));

String simplePriceHkdResponseToJson(SimplePriceHkdResponse data) => json.encode(data.toJson());

class SimplePriceHkdResponse {
    SimplePriceHkdResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceHkdResponse.fromJson(Map<String, dynamic> json) => SimplePriceHkdResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.hkd,
    });

    double hkd;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        hkd: json["hkd"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "hkd": hkd,
    };
}
