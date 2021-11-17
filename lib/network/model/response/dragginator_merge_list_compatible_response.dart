// To parse this JSON data, do
//
//     final dragginatorMergeListCompatibleResponse = dragginatorMergeListCompatibleResponseFromJson(jsonString);

// Dart imports:
import 'dart:convert';

List<String> dragginatorMergeListCompatibleResponseFromJson(String str) =>
    List<String>.from(json.decode(str).map((x) => x));

String dragginatorMergeListCompatibleResponseToJson(List<String> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x)));
