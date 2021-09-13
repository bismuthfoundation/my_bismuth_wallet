// To parse this JSON data, do
//
//     final simplePriceTryResponse = simplePriceTryResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceTryResponse simplePriceTryResponseFromJson(String str) =>
    SimplePriceTryResponse.fromJson(json.decode(str));

String simplePriceTryResponseToJson(SimplePriceTryResponse data) =>
    json.encode(data.toJson());

class SimplePriceTryResponse {
  SimplePriceTryResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceTryResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceTryResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.tryl,
  });

  double tryl;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        tryl: json["try"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "try": tryl,
      };
}
