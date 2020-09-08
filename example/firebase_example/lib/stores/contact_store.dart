import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nano/nano.dart';
import '../models/models.dart';

abstract class ContactMutation {}

class AddContactMutation extends ContactMutation {
  final ContactModel model;
  AddContactMutation(this.model);
}

class DeleteContactMutation extends ContactMutation {
  final ContactModel model;
  DeleteContactMutation(this.model);
}

/// ProxyStream is an older implementation
/// The idea was lift states from another Stream and use it like they are actually apart of this store
/// I didn't find much use case of it, so I'm thinking to remove it
class ContactStore extends Store<ContactList, ContactMutation>
    with ProxyStream<QuerySnapshot> {
  ContactStore() : super(ContactList(status: Status.loading));

  @override
  void mapper({QuerySnapshot event, bool isError = false, Object error}) {
    if (isError) {
      updateStateWithError("Couldn't retrive contacts :/");
    }
    var documents = event.documents;
    if (documents.isEmpty) {
      updateState(ContactList(status: Status.error));
    } else {
      List<ContactModel> contacts =
          documents.map((doc) => ContactModel(name: doc["name"])).toList();
      updateState(ContactList(status: Status.success, contacts: contacts));
    }
  }

  @override
  void reducer(ContactMutation mutation) {
    if (mutation is AddContactMutation) {
      cData.contacts.add(mutation.model);
      updateState(cData);
    }
    if (mutation is DeleteContactMutation) {
      cData.contacts
          .removeWhere((element) => element.name == mutation.model.name);
      updateState(cData);
    }
  }

  @override
  void dispose() {
    super.dispose();
    close();
  }
}
