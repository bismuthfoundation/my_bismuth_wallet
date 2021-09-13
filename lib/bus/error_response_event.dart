import 'package:event_taxi/event_taxi.dart';
import 'package:my_bismuth_wallet/network/model/response/error_response.dart';

class ErrorEvent implements Event {
  final ErrorResponse? response;

  ErrorEvent({this.response});
}
