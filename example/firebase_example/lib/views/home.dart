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
        // builder: (context, state) {
        //   print("STATE - " + state.toString());
        //   if (state.hasError)
        //     return PleaseSignIn();
        //   else
        //     return Provider<ContactState>(
        //       create: (_) {
        //         final contactState = ContactState();
        //         contactState.init(
        //             Firestore.instance.collection("contacts").snapshots());
        //         return contactState;
        //       },
        //       dispose: (_, counterState) => counterState.dispose(),
        //       child: Consumer<ContactState>(
        //         builder: (_, contactState, __) => ContactsView(
        //           authState: authState,
        //           contactState: contactState,
        //         ),
        //       ),
        //     );
        // },
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
              child: Consumer<ContactState>(
                  builder: (_, contactState, __) => ContactsView(
                        authState: authState,
                        contactState: contactState,
                      )));
        },
      ),
    );
  }
}

class PleaseSignIn extends StatelessWidget {
  const PleaseSignIn({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, _) => Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(child: Text("Please Sign In")),
            FlatButton(
              onPressed: () => authState.dispatch(AuthActions.signIn,
                  initialProps: Prop.success(
                      Credentials("example@example.com", "example"))),
              child: Text("Login"),
              color: Colors.blue,
            )
          ],
        ),
      ),
    );
  }
}
