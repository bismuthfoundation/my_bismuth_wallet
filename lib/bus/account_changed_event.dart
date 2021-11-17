// Package imports:
import 'package:event_taxi/event_taxi.dart';

// Project imports:
import 'package:my_bismuth_wallet/model/db/hiveDB.dart';

class AccountChangedEvent implements Event {
  final Account? account;
  final bool delayPop;
  final bool noPop;

  AccountChangedEvent(
      {this.account, this.delayPop = false, this.noPop = false});
}
