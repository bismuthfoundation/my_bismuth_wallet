// To parse this JSON data, do
//
//     final simplePriceSekResponse = simplePriceSekResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceSekResponse simplePriceSekResponseFromJson(String str) =>
    SimplePriceSekResponse.fromJson(json.decode(str));

String simplePriceSekResponseToJson(SimplePriceSekResponse data) =>
    json.encode(data.toJson());

class SimplePriceSekResponse {
  SimplePriceSekResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceSekResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceSekResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.sek,
  });

  double sek;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        sek: json["sek"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "sek": sek,
      };
}
