// To parse this JSON data, do
//
//     final aliasGetResponse = aliasGetResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

List<List<String>> aliasGetResponseFromJson(String str) => List<List<String>>.from(json.decode(str).map((x) => List<String>.from(x.map((x) => x))));

String aliasGetResponseToJson(List<List<String>> data) => json.encode(List<dynamic>.from(data.map((x) => List<dynamic>.from(x.map((x) => x)))));
