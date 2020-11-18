import 'package:event_taxi/event_taxi.dart';
import 'package:my_idena_wallet/network/model/response/address_response.dart';

class PriceEvent implements Event {
  final AddressResponse response;

  PriceEvent({this.response});
}