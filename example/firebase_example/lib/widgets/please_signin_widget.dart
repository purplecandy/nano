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
            if (error is PlatformException &&
                error.code == "ERROR_WRONG_PASSWORD") {
              scaffold.currentState.showSnackBar(SnackBar(
                content: Text("Wrong password"),
                backgroundColor: Colors.redAccent,
              ));
            }
            return error;
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
      body: Center(
        child: Container(
          color: Colors.deepPurple[50],
          height: 250,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Text(
                "Please Sign In",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              )),
              Container(
                padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 0.0),
                width: double.maxFinite,
                child: FlatButton(
                  onPressed: () => handleSignIn(false),
                  child: Text("Login"),
                  textColor: Colors.white,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 0.0),
                width: double.maxFinite,
                child: FlatButton(
                  onPressed: () => handleSignIn(true),
                  child: Text("Try Invalid Login"),
                  textColor: Colors.white,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
