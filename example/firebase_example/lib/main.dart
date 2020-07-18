import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_example/utils.dart';
import 'package:firebase_example/views/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'nanos/auth/auth.dart';

//No need to dispose the providers declared as they are app level now
void main() => runApp(MultiProvider(providers: [
      Provider<AuthState>(
        create: (_) {
          return AuthState()..init(FirebaseAuth.instance.onAuthStateChanged);
        },
      )
    ], child: App()));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        "/": (context) => HomePage(authState: grab<AuthState>(context)),
      },
    );
  }
}
