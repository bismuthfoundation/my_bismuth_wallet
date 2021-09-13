// To parse this JSON data, do
//
//     final simplePriceSgdResponse = simplePriceSgdResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceSgdResponse simplePriceSgdResponseFromJson(String str) =>
    SimplePriceSgdResponse.fromJson(json.decode(str));

String simplePriceSgdResponseToJson(SimplePriceSgdResponse data) =>
    json.encode(data.toJson());

class SimplePriceSgdResponse {
  SimplePriceSgdResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceSgdResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceSgdResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.sgd,
  });

  double sgd;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        sgd: json["sgd"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "sgd": sgd,
      };
}
