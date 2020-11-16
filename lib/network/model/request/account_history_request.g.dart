// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHistoryRequest _$AccountHistoryRequestFromJson(
    Map<String, dynamic> json) {
  return AccountHistoryRequest(
    address: json['address'] as String,
    limit: json['limit'] as int,
  );
}

Map<String, dynamic> _$AccountHistoryRequestToJson(
    AccountHistoryRequest instance) {
  final val = <String, dynamic>{
    'address': instance.address,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('limit', instance.limit);
  return val;
}
