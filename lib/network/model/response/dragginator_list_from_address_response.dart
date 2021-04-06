// To parse this JSON data, do
//
//     final dragginatorListFromAddressResponse = dragginatorListFromAddressResponseFromJson(jsonString);

import 'dart:convert';

List<DragginatorListFromAddressResponse> dragginatorListFromAddressResponseFromJson(String str) => List<DragginatorListFromAddressResponse>.from(json.decode(str).map((x) => DragginatorListFromAddressResponse.fromJson(x)));

String dragginatorListFromAddressResponseToJson(List<DragginatorListFromAddressResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DragginatorListFromAddressResponse {
    DragginatorListFromAddressResponse({
        this.dna,
        this.type,
        this.species,
        this.status,
    });

    String? dna;
    String? type;
    String? species;
    String? status;

    factory DragginatorListFromAddressResponse.fromJson(Map<String, dynamic> json) => DragginatorListFromAddressResponse(
        dna: json["dna"],
        type: json["type"],
        species: json["species"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "dna": dna,
        "type": type,
        "species": species,
        "status": status,
    };
}
