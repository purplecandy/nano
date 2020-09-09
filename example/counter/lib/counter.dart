import 'dart:async';
import 'package:counter/counter_store.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import 'actions.dart';

class CounterApp extends StatefulWidget {
  CounterApp({Key key}) : super(key: key);

  @override
  _CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  final _counter = counterRef.store;
  void autoIncrement() {
    if (_counter.cData < 50) {
      incrementRef(onDone: () async {
        await Future.delayed(Duration(seconds: 1));
        autoIncrement();
      })
        ..run();
    }
  }

  @override
  void initState() {
    super.initState();
    Dispatcher.instance.onActionComplete.listen((event) {
      print(event);
    });
    _counter.addWorker(Worker<int>(
        (e) => e == 4, () => print("Executing worker!!!"),
        limit: 1));
  }

  void handleError(Object error) => print("Error $error");
  void handleDone() => print("Action completed");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Counter State"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.publish),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(appBar: AppBar())));
              })
        ],
      ),
      body: StateBuilder<int>(
        initialState: _counter.state,
        stream: _counter.stream,
        rebuildOnly: (state) => ((state.data ?? 1) % 2 == 0),
        builder: (context, state, init) =>
            Center(child: Text(state.toString())),
        // onError: (_,   error) => Center(child: Text(error.toString())),
        // onData: (_, data) => Center(child: Text(data.toString())),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            mini: true,
            heroTag: null,
            onPressed: () =>
                incrementRef(onError: handleError, onDone: handleDone)..run(),
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            mini: true,
            heroTag: null,
            onPressed: () => decrementRef()..run(),
            child: Icon(Icons.remove),
          ),
          FloatingActionButton(
            mini: true,
            heroTag: null,
            onPressed: autoIncrement,
            child: Icon(Icons.plus_one),
          ),
        ],
      ),
    );
  }
}
