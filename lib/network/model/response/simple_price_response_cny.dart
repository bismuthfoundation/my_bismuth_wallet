// To parse this JSON data, do
//
//     final simplePriceCnyResponse = simplePriceCnyResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceCnyResponse simplePriceCnyResponseFromJson(String str) =>
    SimplePriceCnyResponse.fromJson(json.decode(str));

String simplePriceCnyResponseToJson(SimplePriceCnyResponse data) =>
    json.encode(data.toJson());

class SimplePriceCnyResponse {
  SimplePriceCnyResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceCnyResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceCnyResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.cny,
  });

  double cny;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        cny: json["cny"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "cny": cny,
      };
}
