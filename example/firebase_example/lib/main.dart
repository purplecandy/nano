import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_example/utils.dart';
import 'package:firebase_example/views/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nano/nano.dart';
import 'package:provider/provider.dart';

import 'nanos/auth/auth.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _authState = AuthState();
  @override
  void initState() {
    super.initState();
    _authState.init(FirebaseAuth.instance.onAuthStateChanged);
  }

  @override
  void dispose() {
    _authState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthState>(
      create: (_) => _authState,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          "/": (context) => HomePage(
                authState: grab<AuthState>(context),
              ),
        },
      ),
    );
  }
}
