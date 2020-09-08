import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import '../refs.dart';
import '../refs.dart';
import 'contacts_view.dart';
import '../refs.dart';
import '../stores/auth_store.dart';
import '../widgets/widgets.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  AuthStore authStore = authRef.store;

  @override
  Widget build(BuildContext context) {
    return StateBuilder<FirebaseUser>(
      initialState: authStore.state,
      stream: authStore.stream,
      waiting: (context) => PleaseSignIn(),
      onError: (context, error) => PleaseSignIn(),
      onData: (context, data) => StoreManager(
          recreatable: [contactRef],
          uninitialize: [contactRef],
          child: ContactsView()),
    );
  }
}
