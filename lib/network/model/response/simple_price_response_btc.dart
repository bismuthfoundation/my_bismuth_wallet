// To parse this JSON data, do
//
//     final simplePriceBtcResponse = simplePriceBtcResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceBtcResponse simplePriceBtcResponseFromJson(String str) => SimplePriceBtcResponse.fromJson(json.decode(str));

String simplePriceBtcResponseToJson(SimplePriceBtcResponse data) => json.encode(data.toJson());

class SimplePriceBtcResponse {
    SimplePriceBtcResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceBtcResponse.fromJson(Map<String, dynamic> json) => SimplePriceBtcResponse(
        bismuth: Bismuth.fromJson(json["bismuth"]),
    );

    Map<String, dynamic> toJson() => {
        "bismuth": bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.btc,
    });

    double btc;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        btc: json["btc"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "btc": btc,
    };
}
