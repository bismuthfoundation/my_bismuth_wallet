import 'package:event_taxi/event_taxi.dart';
import 'package:my_idena_wallet/model/db/contact.dart';

class ContactModifiedEvent implements Event {
  final Contact contact;

  ContactModifiedEvent({this.contact});
}