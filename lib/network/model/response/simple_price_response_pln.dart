// To parse this JSON data, do
//
//     final simplePricePlnResponse = simplePricePlnResponseFromJson(jsonString);

import 'dart:convert';

SimplePricePlnResponse simplePricePlnResponseFromJson(String str) => SimplePricePlnResponse.fromJson(json.decode(str));

String simplePricePlnResponseToJson(SimplePricePlnResponse data) => json.encode(data.toJson());

class SimplePricePlnResponse {
    SimplePricePlnResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePricePlnResponse.fromJson(Map<String, dynamic> json) => SimplePricePlnResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.pln,
    });

    double pln;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        pln: json["pln"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "pln": pln,
    };
}
