import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import 'package:provider/provider.dart';

import 'package:firebase_example/widgets.dart';
import 'package:auth/auth.dart';
import 'package:contacts/contacts.dart';
import 'package:firebase_example/utils.dart';

class HomePage extends StatefulWidget {
  final AuthState authState;
  HomePage({Key key, this.authState}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthState get authState => widget.authState;
  @override
  Widget build(BuildContext context) {
    return StateBuilder<FirebaseUser>(
      initialState: authState.state,
      stream: authState.stream,
      builder: (context, state, init) {
        if (state.hasError || init == false)
          return PleaseSignIn(
            authState: authState,
          );
        else
          return Provider<ContactState>(
            create: (_) {
              return ContactState()
                ..init(Firestore.instance.collection("contacts").snapshots());
            },
            dispose: (_, counterState) => counterState.dispose(),
            builder: (context, _) => ContactsView(
              authState: authState,
              contactState: grab<ContactState>(context),
            ),
          );
      },
      // waiting: (context) => PleaseSignIn(),
      // onError: (context, error) => PleaseSignIn(),
      // onData: (context, data) {
      //   print(data);
      //   return Provider<ContactState>(
      //       create: (_) {
      //         final contactState = ContactState();
      //         contactState.init(
      //             Firestore.instance.collection("contacts").snapshots());
      //         return contactState;
      //       },
      //       dispose: (_, counterState) => counterState.dispose(),
      //       child: Consumer<ContactState>(
      //           builder: (_, contactState, __) => ContactsView(
      //                 authState: authState,
      //                 contactState: contactState,
      //               )));
      // },
    );
  }
}
