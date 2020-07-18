import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import 'nanos/auth/auth.dart';

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
