// To parse this JSON data, do
//
//     final mpgetforResponse = mpgetforResponseFromJson(jsonString);

import 'dart:convert';

List<List<dynamic>> mpgetforResponseFromJson(String str) => List<List<dynamic>>.from(json.decode(str).map((x) => List<dynamic>.from(x.map((x) => x))));

String mpgetforResponseToJson(List<List<dynamic>> data) => json.encode(List<dynamic>.from(data.map((x) => List<dynamic>.from(x.map((x) => x)))));
