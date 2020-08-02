# Quickstart

Here we will try to create a simple Counter app. I will be writing more tutorial about some large which will help you understand the goal of this library a lot better.

## Creating a store

We need to create a `Store` to keep our counts track and to update the listeners automatically on every change.

To create a store we need to extend our class with `Store` provided from the `nano` package

```dart
class CounterStore extends Store<int, CounterMutations> {
  CounterStore() : super(0);
}
```

!!! question "What is int and CounterMutations?"

    The first type of the `Store` is the type of our state that we are going to emit. Here we are going to emit integers so it's `int` incase of a string it will be `String` this will prevent you from emiting anything other than the state defined

    The second type of the `Store` is the type of mutations. Every store responds to specific mutations, if correct mutation is received it will be send to the reducer to modify the state. We are going to define `CounterMutations` in next step.


We have now defined our store and the argument passed to `super()` is the inital state. If we don't pass any argument the inital state will not be set and all the listeners will receive a waiting state which basically means that the Store hasn't emitted any events yet.

### Define Mutations

Mutations are specific event which our store recognizes and responds to it.

Here I'm defining class based mutations, it isn't necessary to use class based mutations simple can enums can also be use but when we want some inputs with our mutations it's better to use class based mutations as you can take the benefit of linting with static typing.
```dart
abstract class CounterMutations {}

class IncrementMutation extends CounterMutations {}

class DecrementMutation extends CounterMutations {}

class ErrorMutation extends CounterMutations {}

class CountMutation extends CounterMutations {
  final int count;
  CountMutation(this.count);
}
```

Now I can't send any mutations other than `IncrementMutation`, `DecrementMutation`, `ErrorMutation` and `CountMutation`.

### Defining Reducer

In nano every store has it's own reducer. Reducer sole job is to respond to the mutations received.

Now we will override the reducer from `Store` in our `CounterStore`

```dart
class CounterStore extends Store<int, CounterMutations> {
  CounterStore() : super(0);

  @override
  void reducer(mutation) {
    if (mutation is IncrementMutation) updateState(cData + 1);
    if (mutation is DecrementMutation) updateState(cData - 1);
    if (mutation is ErrorMutation) updateStateWithError("Invalid mutation");
    if (mutation is CountMutation) updateState(mutation.count);
  }
}
```

The `Store` provides you two functions `updateState()` and `updateStateWithError()` which update the state and all the listners receive the latest copy of the state.

When `updateState` is called the listeners receive a data event and the `onData` callback is called.

When `updateStateWithError` is called the listeners receive an error event and the `onErro` callback is called.

!!! warning "Please call updateState in reducer() only"

    Don't create any other function or directly try to mutate the state. The way abstraction works in Dart the two functions for updating state `updateState` and `updateStateWithError` couldn't be hidden outside the class defination but please only call it in your reducer.

## Defining Actions

Mutations can't be send directly to the store they are sent through Actions but since Actions also plays a major role like making async calls and once Action can cause mutation to multiple stores, when we say Actions causes change we don't strictly imply that. Actions carry the mutations and actions are added to the Dispatcher. The dispatcher waits for the Actions to complete and then it sends to the mutation to the respective stores.

We will create action references and whenever we need to create an action we will call the refernce. References can be global as they are immutable but it's better you create them as static members inside a class

First we will create a file `actions.dart` in our lib folder.

Then paste the following code in the file

```dart
//Actions
final incrementRef = ActionRef<CounterStore, Null>(
  mutations: (_, payload) => [Mutation(payload, IncrementMutation())],
);

final decrementRef = ActionRef<CounterStore, Null>(
  mutations: (_, payload) => [Mutation(payload, DecrementMutation())],
);
final errortRef = ActionRef<CounterStore, Null>(
  mutations: (_, payload) => [Mutation(payload, ErrorMutation())],
);

final setRef = ActionRef<CounterParam, void>(
  body: (payload) async {
    await Future.delayed(Duration(milliseconds: payload.seconds));
  },
  mutations: (result, payload) =>
      [Mutation(payload.store, CountMutation(payload.count))],
);
```

ActionRef has few important parameters

- **body**
    
    - Optional parameter
    - Perform all async operations here like API calls fetching from data base
    - returns a `List<Mutation(store,type)>` 

- **mutations**
    
    - Required paramter
    - Takes 2 paramter `result` the returned value of `body()` and `payload` for dependcy injection



## Creating our widget

```dart
class CounterApp extends StatefulWidget {
  CounterApp({Key key}) : super(key: key);

  @override
  _CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  final _counter = CounterState();

  void handleIncrement() => incrementRef(_counter).run();
  void handleDecrement() => decrementRef(_counter).run();
  void handleError() => errorRef(_counter).run();
  void handleCount() => setRef(CounterParam(_counter, 5)).run();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(title: Text("Counter")),
        body: StateBuilder<int>(
          initialState: _counter.state,
          stream: _counter.stream,
          rebuildOnly: (state) => ((state.data ?? 1) % 2 == 0),
          builder: (context, state, init) => 
          Center(child: Text(state.toString())),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              mini: true,
              heroTag: null,
              onPressed: handleIncrement,
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              mini: true,
              heroTag: null,
              onPressed: handleDecrement,
              child: Icon(Icons.remove),
            ),
            FloatingActionButton(
              mini: true,
              heroTag: null,
              onPressed: handleError,
              child: Icon(Icons.close),
            ),
            FloatingActionButton(
              mini: true,
              heroTag: null,
              onPressed: handleCount,
              child: Icon(Icons.plus_one),
            ),
          ],
        ),
    );
  }
}
```

The `StateBuilder` widget takes the `Store` and listens for event. It might look very raw as because the depency inject is very loosely coupled so anyone can use their favourite depency injection library.

## Creating views

Views are the integrating point this is where we build our widget tree and integrate everything.

Create a file name `views.dart` and paste the following code.

```dart

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CounterApp());
  }
}
```