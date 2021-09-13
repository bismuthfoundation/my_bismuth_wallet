// To parse this JSON data, do
//
//     final simplePriceThbResponse = simplePriceThbResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceThbResponse simplePriceThbResponseFromJson(String str) =>
    SimplePriceThbResponse.fromJson(json.decode(str));

String simplePriceThbResponseToJson(SimplePriceThbResponse data) =>
    json.encode(data.toJson());

class SimplePriceThbResponse {
  SimplePriceThbResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceThbResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceThbResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.thb,
  });

  double thb;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        thb: json["thb"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "thb": thb,
      };
}
