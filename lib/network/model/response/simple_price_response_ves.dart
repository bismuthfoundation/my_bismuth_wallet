// To parse this JSON data, do
//
//     final simplePriceVesResponse = simplePriceVesResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceVesResponse simplePriceVesResponseFromJson(String str) => SimplePriceVesResponse.fromJson(json.decode(str));

String simplePriceVesResponseToJson(SimplePriceVesResponse data) => json.encode(data.toJson());

class SimplePriceVesResponse {
    SimplePriceVesResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceVesResponse.fromJson(Map<String, dynamic> json) => SimplePriceVesResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.ves,
    });

    double ves;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        ves: json["ves"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "ves": ves,
    };
}
