// To parse this JSON data, do
//
//     final simplePriceDkkResponse = simplePriceDkkResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceDkkResponse simplePriceDkkResponseFromJson(String str) =>
    SimplePriceDkkResponse.fromJson(json.decode(str));

String simplePriceDkkResponseToJson(SimplePriceDkkResponse data) =>
    json.encode(data.toJson());

class SimplePriceDkkResponse {
  SimplePriceDkkResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceDkkResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceDkkResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.dkk,
  });

  double dkk;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        dkk: json["dkk"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "dkk": dkk,
      };
}
