import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nano/nano.dart';
import 'counter_state.dart';
import 'middlewares.dart';

class CounterApp extends StatefulWidget {
  CounterApp({Key key}) : super(key: key);

  @override
  _CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  final _counter = CounterState();

  void autoIncrement() {
    if (_counter.cData < 50)
      _counter.dispatch(CounterActions.increment, onSuccess: () async {
        await Future.delayed(Duration(seconds: 1));
        autoIncrement();
      });
  }

  @override
  void initState() {
    super.initState();
    // _counter.setDefaultMiddlewares([LoggerMiddleWare()]);
    _counter.dispatch(CounterActions.increment);
    _counter.dispatch(CounterActions.increment);
    _counter.dispatch(CounterActions.increment);
    _counter.dispatch(CounterActions.increment);
  }

  @override
  Widget build(BuildContext context) {
    return Provider<CounterState>(
      create: (_) => _counter,
      child: Scaffold(
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
          builder: (context, state) => Center(child: Text(state.toString())),
          // onError: (_,   error) => Center(child: Text(error.toString())),
          // onData: (_, data) => Center(child: Text(data.toString())),
        ),
        // body: CounterText(),
        // body: StreamBuilder(
        //   stream: _counter.rawStream,
        //   initialData: _counter.state,
        //   builder: (context, snap) => Text(
        //     snap.hasError ? snap.error.toString() : snap.data.toString(),
        //     style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
        //   ),
        // ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              mini: true,
              heroTag: null,
              onPressed: () => _counter.dispatch(
                CounterActions.increment,
                onDone: () => print("action completed"),
                onSuccess: () => print(_counter.cData),
                onError: (e, stack) => print(stack),
              ),
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              mini: true,
              heroTag: null,
              onPressed: () => _counter.dispatch(CounterActions.decrement),
              child: Icon(Icons.remove),
            ),
            FloatingActionButton(
              mini: true,
              heroTag: null,
              onPressed: () => _counter.dispatch(CounterActions.error),
              child: Icon(Icons.close),
            ),
            FloatingActionButton(
              mini: true,
              heroTag: null,
              onPressed: autoIncrement,
              child: Icon(Icons.plus_one),
            ),
          ],
        ),
      ),
    );
  }
}
