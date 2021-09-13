// To parse this JSON data, do
//
//     final simplePriceClpResponse = simplePriceClpResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceClpResponse simplePriceClpResponseFromJson(String str) =>
    SimplePriceClpResponse.fromJson(json.decode(str));

String simplePriceClpResponseToJson(SimplePriceClpResponse data) =>
    json.encode(data.toJson());

class SimplePriceClpResponse {
  SimplePriceClpResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceClpResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceClpResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.clp,
  });

  double clp;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        clp: json["clp"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "clp": clp,
      };
}
