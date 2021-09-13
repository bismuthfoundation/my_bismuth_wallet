// To parse this JSON data, do
//
//     final simplePriceIlsResponse = simplePriceIlsResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

SimplePriceIlsResponse simplePriceIlsResponseFromJson(String str) =>
    SimplePriceIlsResponse.fromJson(json.decode(str));

String simplePriceIlsResponseToJson(SimplePriceIlsResponse data) =>
    json.encode(data.toJson());

class SimplePriceIlsResponse {
  SimplePriceIlsResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePriceIlsResponse.fromJson(Map<String, dynamic> json) =>
      SimplePriceIlsResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.ils,
  });

  double ils;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        ils: json["ils"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "ils": ils,
      };
}
