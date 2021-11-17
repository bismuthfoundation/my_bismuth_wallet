// Package imports:
import 'package:event_taxi/event_taxi.dart';

// Project imports:
import 'package:my_bismuth_wallet/model/db/hiveDB.dart';

class ContactModifiedEvent implements Event {
  final Contact? contact;

  ContactModifiedEvent({this.contact});
}
