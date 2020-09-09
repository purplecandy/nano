import 'package:demo/refs.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import 'views/app.dart';

void main() {
  runApp(StoreManager(initialize: [dbRef, authRef], child: App()));
}
