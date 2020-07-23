import 'package:nano/nano.dart';

class ContactModel {
  final String name;
  ContactModel({this.name});
}

class ContactList {
  final List<ContactModel> contacts;
  final Status status;
  const ContactList({this.status, this.contacts});
}
