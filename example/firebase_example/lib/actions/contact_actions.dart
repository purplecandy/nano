import 'package:firebase_example/models/contact_models.dart';
import 'package:firebase_example/refs.dart';
import 'package:firebase_example/stores/contact_store.dart';
import 'package:nano/nano.dart';

class ContactActions {
  static final add = ActionRef<ContactModel, ContactModel>(
    store: (_) => contactRef.store,
    mutation: (_, payload) => AddContactMutation(payload),
  );

  static final delete = ActionRef<ContactModel, ContactModel>(
    store: (_) => contactRef.store,
    mutation: (_, payload) => DeleteContactMutation(payload),
  );
}
