// To parse this JSON data, do
//
//     final simplePriceMxnResponse = simplePriceMxnResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceMxnResponse simplePriceMxnResponseFromJson(String str) => SimplePriceMxnResponse.fromJson(json.decode(str));

String simplePriceMxnResponseToJson(SimplePriceMxnResponse data) => json.encode(data.toJson());

class SimplePriceMxnResponse {
    SimplePriceMxnResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceMxnResponse.fromJson(Map<String, dynamic> json) => SimplePriceMxnResponse(
        bismuth: Bismuth.fromJson(json["bismuth"]),
    );

    Map<String, dynamic> toJson() => {
        "bismuth": bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.mxn,
    });

    double mxn;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        mxn: json["mxn"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "mxn": mxn,
    };
}
