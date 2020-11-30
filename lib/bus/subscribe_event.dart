import 'package:event_taxi/event_taxi.dart';
import 'package:my_bismuth_wallet/network/model/response/address_response.dart';

class SubscribeEvent implements Event {
  final AddressResponse response;

  SubscribeEvent({this.response});
}