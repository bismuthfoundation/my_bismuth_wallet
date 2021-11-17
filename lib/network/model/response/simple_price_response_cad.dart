// To parse this JSON data, do
//
//     final simplePriceCadResponse = simplePriceCadResponseFromJson(jsonString);

// @dart=2.9

// Dart imports:
import 'dart:convert';

SimplePriceCadResponse simplePriceCadResponseFromJson(String str) =>
    SimplePriceCadResponse.fromJson(json.decode(str));

String simplePriceCadResponseToJson(SimplePriceCadResponse data) =>
    json.encode(data.toJson());

class SimplePriceCadResponse {
  SimplePriceCadResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceCadResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceCadResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.cad,
  });

  double cad;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        cad: json["cad"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "cad": cad,
      };
}
