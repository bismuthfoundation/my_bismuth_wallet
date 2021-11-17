// To parse this JSON data, do
//
//     final simplePricePhpResponse = simplePricePhpResponseFromJson(jsonString);

// @dart=2.9

// Dart imports:
import 'dart:convert';

SimplePricePhpResponse simplePricePhpResponseFromJson(String str) =>
    SimplePricePhpResponse.fromJson(json.decode(str));

String simplePricePhpResponseToJson(SimplePricePhpResponse data) =>
    json.encode(data.toJson());

class SimplePricePhpResponse {
  SimplePricePhpResponse({
    this.bismuth,
  });

  Bismuth bismuth;

  factory SimplePricePhpResponse.fromJson(Map<String, dynamic> json) =>
      SimplePricePhpResponse(
        bismuth: Bismuth.fromJson(json['bismuth']),
      );

  Map<String, dynamic> toJson() => {
        'bismuth': bismuth.toJson(),
      };
}

class Bismuth {
  Bismuth({
    this.php,
  });

  double php;

  factory Bismuth.fromJson(Map<String, dynamic> json) => Bismuth(
        php: json["php"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "php": php,
      };
}
