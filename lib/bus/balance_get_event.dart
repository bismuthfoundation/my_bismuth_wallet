// Package imports:
import 'package:event_taxi/event_taxi.dart';

// Project imports:
import 'package:my_bismuth_wallet/model/db/hiveDB.dart';
import 'package:my_bismuth_wallet/network/model/response/balance_get_response.dart';

class BalanceGetEvent implements Event {
  final Account? account;
  final BalanceGetResponse? response;

  BalanceGetEvent({this.response, this.account});
}
