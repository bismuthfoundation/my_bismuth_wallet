// To parse this JSON data, do
//
//     final dragginatorInfosFromDnaResponse = dragginatorInfosFromDnaResponseFromJson(jsonString);

import 'dart:convert';

DragginatorInfosFromDnaResponse dragginatorInfosFromDnaResponseFromJson(String str) => DragginatorInfosFromDnaResponse.fromJson(json.decode(str));

String dragginatorInfosFromDnaResponseToJson(DragginatorInfosFromDnaResponse data) => json.encode(data.toJson());

class DragginatorInfosFromDnaResponse {
    DragginatorInfosFromDnaResponse({
        this.type,
        this.species,
        this.rarity,
        this.birth,
        this.owner,
        this.creator,
        this.gen,
        this.globId,
        this.genId,
        this.capacities,
        this.seller,
        this.other,
        this.status,
        this.age,
        this.cost,
        this.dna,
        this.gameAllowed,
        this.huntData,
        this.abilities,
    });

    String? type;
    String? species;
    int? rarity;
    String? birth;
    String? owner;
    String? creator;
    String? gen;
    String? globId;
    String? genId;
    String? capacities;
    String? seller;
    String? other;
    String? status;
    String? age;
    int? cost;
    String? dna;
    bool? gameAllowed;
    dynamic? huntData;
    List<dynamic>? abilities;

    factory DragginatorInfosFromDnaResponse.fromJson(Map<String, dynamic> json) => DragginatorInfosFromDnaResponse(
        type: json["type"],
        species: json["species"],
        rarity: json["rarity"],
        birth: json["birth"],
        owner: json["owner"],
        creator: json["creator"],
        gen: json["gen"],
        globId: json["glob_id"],
        genId: json["gen_id"],
        capacities: json["capacities"],
        seller: json["seller"],
        other: json["other"],
        status: json["status"],
        age: json["age"],
        cost: json["cost"],
        dna: json["dna"],
        gameAllowed: json["game_allowed"],
        huntData: json["hunt_data"],
        abilities: List<dynamic>.from(json["abilities"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "species": species,
        "rarity": rarity,
        "birth": birth,
        "owner": owner,
        "creator": creator,
        "gen": gen,
        "glob_id": globId,
        "gen_id": genId,
        "capacities": capacities,
        "seller": seller,
        "other": other,
        "status": status,
        "age": age,
        "cost": cost,
        "dna": dna,
        "game_allowed": gameAllowed,
        "hunt_data": huntData,
        "abilities": List<dynamic>.from(abilities!.map((x) => x)),
    };
}

class AbilityClass {
    AbilityClass({
        this.strategy,
        this.bravery,
        this.strength,
        this.agility,
        this.power,
        this.stamina,
        this.speed,
        this.health,
    });

    double? strategy;
    double? bravery;
    double? strength;
    double? agility;
    double? power;
    double? stamina;
    double? speed;
    double? health;

    factory AbilityClass.fromJson(Map<String, dynamic> json) => AbilityClass(
        strategy: json["strategy"],
        bravery: json["bravery"],
        strength: json["strength"],
        agility: json["agility"],
        power: json["power"],
        stamina: json["stamina"],
        speed: json["speed"],
        health: json["health"],
    );

    Map<String, dynamic> toJson() => {
        "strategy": strategy,
        "bravery": bravery,
        "strength": strength,
        "agility": agility,
        "power": power,
        "stamina": stamina,
        "speed": speed,
        "health": health,
    };
}
