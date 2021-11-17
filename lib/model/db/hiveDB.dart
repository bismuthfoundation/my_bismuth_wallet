// Package imports:
import 'package:hive/hive.dart';

part 'hiveDB.g.dart';

@HiveType(typeId: 0)
class Contact extends HiveObject {
  Contact({required this.name, required this.address});

  /// Name
  @HiveField(0)
  String? name;

  /// Address
  @HiveField(1)
  String? address;
}

@HiveType(typeId: 1)
class Account extends HiveObject {
  Account(
      {this.index,
      this.name,
      this.lastAccess,
      this.selected = false,
      this.address,
      this.balance,
      this.dragginatorDna,
      this.dragginatorStatus});

  /// Index on the seed
  @HiveField(0)
  int? index;

  /// Account nickname
  @HiveField(1)
  String? name;

  /// Last Accessed incrementor
  @HiveField(2)
  int? lastAccess;

  /// Whether this is the currently selected account
  @HiveField(3)
  bool? selected;

  /// Last address
  @HiveField(4)
  String? address;

  /// Last known balance in RAW
  @HiveField(5)
  String? balance;

  /// Dna Dragginator for avatar
  @HiveField(6)
  String? dragginatorDna;

  @HiveField(7)
  String? dragginatorStatus;
}
