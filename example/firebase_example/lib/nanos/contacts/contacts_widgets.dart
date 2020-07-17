import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';

import 'contacts_state.dart';
import 'contacts_models.dart';

class ContactsWidget extends StatefulWidget {
  ContactsWidget({Key key}) : super(key: key);

  @override
  _ContactsWidgetState createState() => _ContactsWidgetState();
}

class _ContactsWidgetState extends State<ContactsWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ContactState>(
      builder: (context, _contactState, _) => StateBuilder<ContactList>(
        initialState: _contactState.state,
        stream: _contactState.stream,
        onError: (context, error) => Center(
          child: Text(error.toString()),
        ),
        onData: (context, data) {
          switch (data.status) {
            case Status.loading:
              return Center(child: CircularProgressIndicator());
              break;
            case Status.error:
              return Center(child: Text("You don't have any contacts yet."));
              break;
            case Status.success:
              return ListView.builder(
                itemCount: data.contacts.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    title: Text(data.contacts[index].name),
                    trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _contactState.dispatch(ContactAction.delete,
                              initialProps:
                                  Prop.success(data.contacts[index].name));
                        }),
                  ),
                ),
              );
              break;
            default:
              return Container();
          }
        },
      ),
    );
  }
}

class InputWidget extends StatefulWidget {
  final void Function(String name) onCreate;
  const InputWidget({Key key, @required this.onCreate}) : super(key: key);

  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  String input = "";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create contact"),
      content: TextField(
        decoration: InputDecoration(hintText: "Name"),
        onChanged: (val) => setState(() {
          input = val.trim();
        }),
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        FlatButton(
            onPressed: input.isEmpty
                ? null
                : () {
                    widget.onCreate?.call(input);
                    Navigator.pop(context);
                  },
            child: Text("Create")),
      ],
    );
  }
}
