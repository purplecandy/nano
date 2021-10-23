import 'dart:async';
import 'package:counter/actions.dart';
import 'package:counter/counter_store.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import 'package:nano/nano.dart' as n;

class CounterApp extends StatefulWidget {
  CounterApp({Key key}) : super(key: key);

  @override
  _CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  bool isDoubleTaps = true;

  /// We are obtaining our `CounterStore` here
  /// Yes that's it no context or anything except a slight catch
  final _counter = counterRef.store;

  /// The method continously fires Increment action every 1 second until it reaches 50 counts.
  void autoIncrement() {
    if (_counter.cData < 50) {
      /// To execute our action, first we need to call it then you will have an `Action` object
      /// `Action` has a run method, which basically adds the action to the Dispatcher
      ///
      /// The `onDone` is a call back that is executed once the action is completed successfully
      /// There is also an `onError` call back that is executed if there is an exection occur
      n.Action(incrementRef, onError: (error) {
        print("Error $error");
        return;
      }, onDone: () async {
        await Future.delayed(Duration(seconds: 1));
        autoIncrement();
      }).run();
    }
  }

  @override
  void initState() {
    super.initState();

    /// This is how we can globally listen to the dispather
    Dispatcher.instance.onActionComplete.listen((event) {
      print(event);
    });

    /// A worker is call back that get executed once the store reaches the specified state
    /// Here if the count will be 4 it will print Executing worke!!
    /// you can also pass a limit to automatically remove it after x amout of time
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
          FlatButton(
              child: Text(isDoubleTaps ? "Set Single" : "Set Double"),
              onPressed: () {
                setState(() {
                  isDoubleTaps = !isDoubleTaps;
                });
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => Scaffold(appBar: AppBar())));
              })
        ],
      ),

      /// StateBuilder is our StreamBuilder
      /// It does the same job exactly like it but it returns state in a more convinent way
      /// `initialState` is usuall the current state of the store or you can specificy if you wantt to
      /// `stream` you get this from the store itself
      body: StateBuilder<int>(
        initialState: _counter.state,
        stream: _counter.stream,
        rebuildOnly: (old, state) =>
            isDoubleTaps ? ((state.data ?? 1) % 2 == 0) : true,
        builder: (context, state, init) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDoubleTaps) Text("Rebuilds only on double taps!"),
            Center(child: Text(state.toString())),
          ],
        ),
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

                /// If this is tapped, dispatch this action.
                /// Incase if it fails execute `handleError` otherwise `handleDone`
                // incrementRef(onError: handleError, onDone: handleDone)..run(),
                n.Action(incrementRef, onError: (error) {
              print("Error $error");
              return;
            }, onDone: handleDone)
                    .run(),
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            mini: true,
            heroTag: null,
            onPressed: () => n.Action(decrementRef, onError: (error) {
              print("Error $error");
              return;
            }, onDone: handleDone)
                .run(),
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
