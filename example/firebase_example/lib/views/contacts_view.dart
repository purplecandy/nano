import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import '../refs.dart';
import '../refs.dart';
import '../stores/auth_store.dart';
import '../stores/stores.dart';
import 'contacts_widgets.dart';

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
  }

  void onCreate(String name) {
    // contactState.dispatch(ContactAction.add, initialProps: Prop.success(name));
  }

  @override
  Widget build(BuildContext context) {
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
