import 'package:flutter/material.dart';

class AuthentiateView extends StatefulWidget {
  AuthentiateView({Key key}) : super(key: key);

  @override
  _AuthentiateViewState createState() => _AuthentiateViewState();
}

class _AuthentiateViewState extends State<AuthentiateView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Authenticate")),
    );
  }
}
