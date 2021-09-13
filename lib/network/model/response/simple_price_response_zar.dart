// To parse this JSON data, do
//
//     final simplePriceZarResponse = simplePriceZarResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceZarResponse simplePriceZarResponseFromJson(String str) =>
    SimplePriceZarResponse.fromJson(json.decode(str));

String simplePriceZarResponseToJson(SimplePriceZarResponse data) =>
    json.encode(data.toJson());

class SimplePriceZarResponse {
  SimplePriceZarResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceZarResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceZarResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.zar,
  });

  double zar;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        zar: json["zar"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "zar": zar,
      };
}
