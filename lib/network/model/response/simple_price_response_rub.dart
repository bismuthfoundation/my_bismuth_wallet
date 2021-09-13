// To parse this JSON data, do
//
//     final simplePriceRubResponse = simplePriceRubResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceRubResponse simplePriceRubResponseFromJson(String str) =>
    SimplePriceRubResponse.fromJson(json.decode(str));

String simplePriceRubResponseToJson(SimplePriceRubResponse data) =>
    json.encode(data.toJson());

class SimplePriceRubResponse {
  SimplePriceRubResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceRubResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceRubResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.rub,
  });

  double rub;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        rub: json["rub"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "rub": rub,
      };
}
