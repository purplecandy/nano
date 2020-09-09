import 'package:demo/models/auth_model.dart';
import 'package:demo/refs.dart';
import 'package:demo/views/authenticate.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final authStore = authRef.store;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo App"),
      ),
      body: Text("Hello World"),
    );
  }
}
