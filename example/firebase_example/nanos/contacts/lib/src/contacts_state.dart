import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nano/nano.dart';

import 'contacts_models.dart';

enum ContactAction {
  add,
  delete,
}

class ContactState extends Store<ContactList, ContactAction>
    with ProxyStream<QuerySnapshot> {
  ContactState() : super(ContactList(status: Status.loading));

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
  Future<void> reducer(ContactAction action) async {
    // String name = props.data
    // switch (action) {
    //   case ContactAction.add:
    //     Firestore.instance
    //         .collection("contacts")
    //         .document(name)
    //         .setData({"name": name});

    //     break;
    //   case ContactAction.delete:
    //     Firestore.instance.collection("contacts").document(name).delete();
    //     break;
    //   default:
    // }
  }

  @override
  void dispose() {
    super.dispose();
    close();
  }
}
