// Package imports:
import 'package:event_taxi/event_taxi.dart';

// Project imports:
import 'package:my_bismuth_wallet/network/model/response/wstatusget_response.dart';

class WStatusGetEvent implements Event {
  final WStatusGetResponse? response;

  WStatusGetEvent({this.response});
}
