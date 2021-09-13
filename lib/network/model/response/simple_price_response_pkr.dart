// To parse this JSON data, do
//
//     final simplePricePkrResponse = simplePricePkrResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePricePkrResponse simplePricePkrResponseFromJson(String str) =>
    SimplePricePkrResponse.fromJson(json.decode(str));

String simplePricePkrResponseToJson(SimplePricePkrResponse data) =>
    json.encode(data.toJson());

class SimplePricePkrResponse {
  SimplePricePkrResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePricePkrResponse.fromJson(Map<String, dynamic> json) =>
      SimplePricePkrResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.pkr,
  });

  double pkr;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        pkr: json["pkr"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "pkr": pkr,
      };
}
