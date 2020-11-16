// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history_response_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHistoryResponseItem _$AccountHistoryResponseItemFromJson(
    Map<String, dynamic> json) {
  return AccountHistoryResponseItem(
    hash: json['hash'] as String,
    type: json['type'] as String,
    timestamp: json['timestamp'] as String,
    from: json['from'] as String,
    amount: json['amount'] as String,
    tips: json['tips'] as String,
    maxFee: json['maxFee'] as String,
    account: json['account'] as String,
    fee: json['fee'] as String,
    size: json['size'] as int,
  );
}

Map<String, dynamic> _$AccountHistoryResponseItemToJson(
        AccountHistoryResponseItem instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'type': instance.type,
      'timestamp': instance.timestamp,
      'from': instance.from,
      'amount': instance.amount,
      'tips': instance.tips,
      'maxFee': instance.maxFee,
      'account': instance.account,
      'fee': instance.fee,
      'size': instance.size,
    };
