// To parse this JSON data, do
//
//     final simplePriceNzdResponse = simplePriceNzdResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceNzdResponse simplePriceNzdResponseFromJson(String str) =>
    SimplePriceNzdResponse.fromJson(json.decode(str));

String simplePriceNzdResponseToJson(SimplePriceNzdResponse data) =>
    json.encode(data.toJson());

class SimplePriceNzdResponse {
  SimplePriceNzdResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceNzdResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceNzdResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.nzd,
  });

  double nzd;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        nzd: json["nzd"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "nzd": nzd,
      };
}
