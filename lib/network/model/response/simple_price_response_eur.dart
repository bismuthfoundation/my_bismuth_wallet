// To parse this JSON data, do
//
//     final simplePriceEurResponse = simplePriceEurResponseFromJson(jsonString);

// @dart=2.9

// Dart imports:
import 'dart:convert';

SimplePriceEurResponse simplePriceEurResponseFromJson(String str) =>
    SimplePriceEurResponse.fromJson(json.decode(str));

String simplePriceEurResponseToJson(SimplePriceEurResponse data) =>
    json.encode(data.toJson());

class SimplePriceEurResponse {
  SimplePriceEurResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceEurResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceEurResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.eur,
  });

  double eur;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        eur: json["eur"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "eur": eur,
      };
}
