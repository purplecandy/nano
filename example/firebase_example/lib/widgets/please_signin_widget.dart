import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../actions/actions.dart';
import '../models/models.dart';

class PleaseSignIn extends StatelessWidget {
  final scaffold = GlobalKey<ScaffoldState>();
  PleaseSignIn({Key key}) : super(key: key);

  void handleSignIn(bool failed) {
    if (failed)
      AuthActions.signInAction(
          payload: Credentials("example@example.com", "1234"),
          onError: (error) {
            if (error is PlatformException) {
              if (error.code == "ERROR_WRONG_PASSWORD") {
                scaffold.currentState.showSnackBar(SnackBar(
                  content: Text("Wrong password"),
                  backgroundColor: Colors.redAccent,
                ));
              }
            }
            return null;
          })
        ..run();
    else
      AuthActions.signInAction(
          payload: Credentials("example@example.com", "example"))
        ..run();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(child: Text("Please Sign In")),
          FlatButton(
            onPressed: () => handleSignIn(false),
            child: Text("Login"),
            color: Colors.blue,
          ),
          FlatButton(
            onPressed: () => handleSignIn(true),
            child: Text("Try Invalid Login"),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
