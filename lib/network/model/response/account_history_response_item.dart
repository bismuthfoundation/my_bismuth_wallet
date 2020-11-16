import 'package:json_annotation/json_annotation.dart';

import 'package:my_idena_wallet/model/address.dart';
import 'package:my_idena_wallet/util/numberutil.dart';

part 'account_history_response_item.g.dart';

@JsonSerializable()
class AccountHistoryResponseItem {
  @JsonKey(name:'hash')
  String hash;

  @JsonKey(name:'type')
  String type;

  @JsonKey(name:'timestamp')
  String timestamp;

  @JsonKey(name:'from')
  String from;

  @JsonKey(name:'amount')
  String amount;

  @JsonKey(name:'tips')
  String tips;

  @JsonKey(name:'maxFee')
  String maxFee;

  @JsonKey(name:'account')
  String account;

  @JsonKey(name:'fee')
  String fee;

  @JsonKey(name:'size')
  int size;

  AccountHistoryResponseItem({String hash, String type, String timestamp, String from, String amount, String tips, String maxFee, 
  String account, String fee, int size}) {
    this.hash = hash;
    this.type = type;
    this.timestamp = timestamp;
    this.from = from;
    this.amount = amount;
    this.tips = tips;
    this.maxFee = maxFee;
    this.account = account;
    this.fee = fee;
    this.size = size;
  }

  String getShortString() {
    return new Address(this.account).getShortString();
  }

  String getShorterString() {
    return new Address(this.account).getShorterString();
  }

  /**
   * Return amount formatted for use in the UI
   */
  String getFormattedAmount() {
    return NumberUtil.getRawAsUsableString(amount);
  }

  factory AccountHistoryResponseItem.fromJson(Map<String, dynamic> json) => _$AccountHistoryResponseItemFromJson(json);
  Map<String, dynamic> toJson() => _$AccountHistoryResponseItemToJson(this);

  bool operator ==(o) => o is AccountHistoryResponseItem && o.hash == hash;
  int get hashCode => hash.hashCode;
}