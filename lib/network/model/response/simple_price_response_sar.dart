// To parse this JSON data, do
//
//     final simplePriceSarResponse = simplePriceSarResponseFromJson(jsonString);

import 'dart:convert';

SimplePriceSarResponse simplePriceSarResponseFromJson(String str) => SimplePriceSarResponse.fromJson(json.decode(str));

String simplePriceSarResponseToJson(SimplePriceSarResponse data) => json.encode(data.toJson());

class SimplePriceSarResponse {
    SimplePriceSarResponse({
        this.bismuth,
    });

    Bismuth bismuth;

    factory SimplePriceSarResponse.fromJson(Map<String, dynamic> json) => SimplePriceSarResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
    );

    Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
    };
}

class Bismuth {
    Bismuth({
        this.sar,
    });

    double sar;

    factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        sar: json["sar"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "sar": sar,
    };
}
