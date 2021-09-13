// To parse this JSON data, do
//
//     final simplePriceNokResponse = simplePriceNokResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceNokResponse simplePriceNokResponseFromJson(String str) =>
    SimplePriceNokResponse.fromJson(json.decode(str));

String simplePriceNokResponseToJson(SimplePriceNokResponse data) =>
    json.encode(data.toJson());

class SimplePriceNokResponse {
  SimplePriceNokResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceNokResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceNokResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.nok,
  });

  double nok;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        nok: json["nok"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "nok": nok,
      };
}
