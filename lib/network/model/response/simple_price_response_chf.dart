// To parse this JSON data, do
//
//     final simplePriceChfResponse = simplePriceChfResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceChfResponse simplePriceChfResponseFromJson(String str) => SimplePriceChfResponse.fromJson(json.decode(str));

String simplePriceChfResponseToJson(SimplePriceChfResponse data) => json.encode(data.toJson());

class SimplePriceChfResponse {
    SimplePriceChfResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceChfResponse.fromJson(Map<String, dynamic> json) => SimplePriceChfResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.chf,
    });

    double chf;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        chf: json["chf"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "chf": chf,
    };
}
