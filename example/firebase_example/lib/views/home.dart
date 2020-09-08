import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';

import '../refs.dart';
import '../stores/auth_store.dart';
import '../widgets.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  AuthStore authStore = authRef.store;
  @override
  void initState() {
    super.initState();
    // Pool().create(contactRef);
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<FirebaseUser>(
      initialState: authStore.state,
      stream: authStore.stream,
      builder: (context, state, init) {
        if (state.hasError || init == false)
          return PleaseSignIn();
        else
          return LoggedIn();
        // return InitializeStore<ContactState>(
        //   storeToken: contactRef,
        //   dispose: (contactState) {
        //     print("Disposing contact state");
        //     contactState.dispose();
        //   },
        //   child: (store) => ContactsView(
        //     authState: authState,
        //     contactState: store,
        //   ),
        // );
        // return Provider<ContactState>(
        //   create: (_) {
        //     return ContactState()
        //       ..init(Firestore.instance.collection("contacts").snapshots());
        //   },
        //   dispose: (_, counterState) => counterState.dispose(),
        //   builder: (context, _) => ContactsView(
        //     authState: authState,
        //     contactState: Pool().obtain<ContactState>(contactRef),
        //   ),
        // );
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

class LoggedIn extends StatefulWidget {
  LoggedIn({Key key}) : super(key: key);

  @override
  _LoggedInState createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> {
  @override
  Widget build(BuildContext context) {
    final authState = Pool().obtain(authRef);
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        actions: <Widget>[
          // FlatButton(
          //     onPressed: () =>
          //         Dispatcher.instance.add(AuthActions.signOutAction(authState)),
          //     child: Text("Logout"))
        ],
      ),
    );
  }
}
