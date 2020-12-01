import 'package:event_taxi/event_taxi.dart';
import 'package:my_bismuth_wallet/network/model/response/balance_get_response.dart';

class SubscribeEvent implements Event {
  final BalanceGetResponse response;

  SubscribeEvent({this.response});
}