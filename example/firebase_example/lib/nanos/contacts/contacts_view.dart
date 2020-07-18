import 'package:flutter/material.dart';
import 'package:nano/nano.dart';

import '../auth/auth.dart';
import 'contacts_state.dart';
import 'contacts_widgets.dart';

class ContactsView extends StatefulWidget {
  final ContactState contactState;
  final AuthState authState;
  ContactsView({Key key, this.contactState, this.authState}) : super(key: key);

  @override
  _ContactsViewState createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  ContactState get contactState => widget.contactState;
  AuthState get authState => widget.authState;
  @override
  void initState() {
    super.initState();
  }

  void onCreate(String name) {
    contactState.dispatch(ContactAction.add, initialProps: Prop.success(name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        actions: <Widget>[
          FlatButton(
              onPressed: () => authState.dispatch(AuthActions.signOut),
              child: Text("Logout"))
        ],
      ),
      body: ContactsWidget(
        contactState: contactState,
      ),
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
