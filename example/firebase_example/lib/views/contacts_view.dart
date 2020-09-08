import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_example/models/contact_models.dart';
import 'package:flutter/material.dart';
import '../actions/actions.dart';
import 'live_search.dart';
import '../refs.dart';
import '../stores/auth_store.dart';
import '../stores/stores.dart';
import '../widgets/widgets.dart';

class ContactsView extends StatefulWidget {
  ContactsView({Key key}) : super(key: key);

  @override
  _ContactsViewState createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  ContactStore contactStore = contactRef.store;
  AuthStore authStore = authRef.store;
  @override
  void initState() {
    super.initState();
    contactStore.init(Firestore.instance.collection("contacts").snapshots());
  }

  void onCreate(String name) {
    ContactActions.add(payload: ContactModel(name: name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => LiveSearchView()));
              }),
          FlatButton(
              onPressed: () => AuthActions.signOutAction().run(),
              child: Text("Logout"))
        ],
      ),
      body: ContactsWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => InputWidget(onCreate: onCreate));
        },
        tooltip: 'Create contact',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
