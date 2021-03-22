// To parse this JSON data, do
//
//     final simplePriceHufResponse = simplePriceHufResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceHufResponse simplePriceHufResponseFromJson(String str) => SimplePriceHufResponse.fromJson(json.decode(str));

String simplePriceHufResponseToJson(SimplePriceHufResponse data) => json.encode(data.toJson());

class SimplePriceHufResponse {
    SimplePriceHufResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceHufResponse.fromJson(Map<String, dynamic> json) => SimplePriceHufResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.huf,
    });

    double huf;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        huf: json["huf"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "huf": huf,
    };
}
