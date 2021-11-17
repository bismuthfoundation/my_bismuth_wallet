// Package imports:
import 'package:event_taxi/event_taxi.dart';

// Project imports:
import 'package:my_bismuth_wallet/model/db/hiveDB.dart';

class ContactAddedEvent implements Event {
  final Contact? contact;

  ContactAddedEvent({this.contact});
}
