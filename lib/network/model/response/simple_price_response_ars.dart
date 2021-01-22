// To parse this JSON data, do
//
//     final simplePriceArsResponse = simplePriceArsResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceArsResponse simplePriceArsResponseFromJson(String str) => SimplePriceArsResponse.fromJson(json.decode(str));

String simplePriceArsResponseToJson(SimplePriceArsResponse data) => json.encode(data.toJson());

class SimplePriceArsResponse {
    SimplePriceArsResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceArsResponse.fromJson(Map<String, dynamic> json) => SimplePriceArsResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.ars,
    });

    double ars;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        ars: json["ars"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "ars": ars,
    };
}
