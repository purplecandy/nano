import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:nano/nano.dart';

import '../auth/auth.dart';
import 'contacts_state.dart';
import 'contacts_widgets.dart';

class ContactsView extends StatefulWidget {
  ContactsView({Key key}) : super(key: key);

  @override
  _ContactsViewState createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  ContactState _contactState;
  AuthState _authState;
  @override
  void initState() {
    super.initState();
    _contactState = Provider.of<ContactState>(context, listen: false);
    _authState = Provider.of<AuthState>(context, listen: false);
  }

  void onCreate(String name) {
    _contactState.dispatch(ContactAction.add, initialProps: Prop.success(name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.subdirectory_arrow_right),
              onPressed: () => _authState.dispatch(AuthActions.signIn,
                  initialProps: Prop.success(
                      Credentials("example@example.com", "example")))),
          IconButton(
              icon: Icon(Icons.subdirectory_arrow_left),
              onPressed: () => _authState.dispatch(AuthActions.signOut))
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
