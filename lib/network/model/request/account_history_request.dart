import 'package:json_annotation/json_annotation.dart';
import 'package:my_idena_wallet/network/model/base_request.dart';

part 'account_history_request.g.dart';

@JsonSerializable()
class AccountHistoryRequest extends BaseRequest {
  @JsonKey(name:'address')
  String address;

  @JsonKey(name:'limit', includeIfNull: false)
  int limit;

  AccountHistoryRequest({String address, int limit}):super() {
    this.address = address ?? "";
    this.limit = limit ?? 30;
  }

  factory AccountHistoryRequest.fromJson(Map<String, dynamic> json) => _$AccountHistoryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AccountHistoryRequestToJson(this);
}