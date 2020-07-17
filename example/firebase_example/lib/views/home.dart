import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_example/nanos/auth/auth.dart';
import 'package:firebase_example/nanos/contacts/contacts.dart';
import 'package:firebase_example/nanos/contacts/contacts_view.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, _) => StateBuilder<FirebaseUser>(
        initialState: authState.state,
        stream: authState.stream,
        onError: (context, error) => PleaseSignIn(),
        onData: (context, data) {
          print(data);
          return Provider<ContactState>(
              create: (_) {
                final contactState = ContactState();
                contactState.init(
                    Firestore.instance.collection("contacts").snapshots());
                return contactState;
              },
              dispose: (_, counterState) => counterState.dispose(),
              child: ContactsView());
        },
      ),
    );
  }
}

class PleaseSignIn extends StatelessWidget {
  const PleaseSignIn({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Please Sign In"),
      ),
    );
  }
}
