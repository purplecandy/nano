import 'package:flutter/material.dart';
import 'package:nano/nano.dart';

import '../refs.dart';
import '../refs.dart';
import 'home.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Pool().create(authRef);
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        "/": (context) => StoreManager(
            recreatable: [],
            uninitialize: [],
            initialize: [authRef],
            dispose: [authRef],
            child: HomeView()),
      },
    );
  }
}
