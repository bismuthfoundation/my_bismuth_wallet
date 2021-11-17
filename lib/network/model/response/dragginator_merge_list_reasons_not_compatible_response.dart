// To parse this JSON data, do
//
//     final dragginatorMergeListReasonsNotCompatibleResponse = dragginatorMergeListReasonsNotCompatibleResponseFromJson(jsonString);

// Dart imports:
import 'dart:convert';

List<String> dragginatorMergeListReasonsNotCompatibleResponseFromJson(
        String str) =>
    List<String>.from(json.decode(str).map((x) => x));

String dragginatorMergeListReasonsNotCompatibleResponseToJson(
        List<String> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x)));
