import 'package:flutter/material.dart';
import 'package:nano/nano.dart';

import 'stores/auth_store.dart';

class PleaseSignIn extends StatelessWidget {
  const PleaseSignIn({Key key}) : super(key: key);

  void handleSignIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(child: Text("Please Sign In")),
          FlatButton(
            onPressed: handleSignIn,
            child: Text("Login"),
            color: Colors.blue,
          ),
          FlatButton(
            onPressed: handleSignIn,
            child: Text("Try Invalid Login"),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
