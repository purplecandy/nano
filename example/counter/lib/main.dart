import 'package:counter/counter_store.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import 'counter.dart';

void main() => runApp(MaterialApp(
        home: StoreManager(
      initialize: [counterRef],
      onInit: () => print("Hello Counter"),
      child: CounterApp(),
    )));
