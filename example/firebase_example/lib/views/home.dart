import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_example/nanos/auth/auth.dart';
import 'package:firebase_example/nanos/contacts/contacts.dart';
import 'package:firebase_example/nanos/contacts/contacts_view.dart';
import 'package:firebase_example/utils.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import 'package:provider/provider.dart';

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
            authState: grab<AuthState>(context),
          );
        else
          return Provider<ContactState>(
              create: (_) {
                final contactState = ContactState();
                contactState.init(
                    Firestore.instance.collection("contacts").snapshots());
                return contactState;
              },
              dispose: (_, counterState) => counterState.dispose(),
              builder: (context, _) => ContactsView(
                    authState: grab<AuthState>(context),
                    contactState: grab<ContactState>(context),
                  )
              // Consumer<ContactState>(
              //   builder: (_, contactState, __) => ContactsView(
              //     authState: authState,
              //     contactState: contactState,
              //   ),
              // ),
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

class PleaseSignIn extends StatelessWidget {
  final AuthState authState;
  const PleaseSignIn({Key key, this.authState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
