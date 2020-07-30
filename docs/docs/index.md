# Introduction
*Nano isn't production-ready yet, it's in an early stage of development, you can always create an issue for suggestions*

An application architecture pattern than a framework for Flutter utilizing a unidirectional data flow.

The goal of Nano is to make it easy to separate the business logic from the presentation layer, with modular state management to allow developers to build smaller parts, that can be tested in isolation. Nano is highly focused on architectural pattern and code structure that's scalable and modular to increase code re-usability with less to no refactoring.

Nano is heavily inspired by existing solutions like Redux, BLoC pattern and Flux. Internally Nano has nothing out of ordinary for state management, it's just streams on top of rxdart and some helper functions to make your life easier. 
****
Nano's unidirectional data flow diagram

![Nano diagram](assets/nano-diagram.png)


**State Manager**

State Manager holds the state of the component, the state is immutable and only be modified from calling `Actions`.

State Manager provides provides a stream of that can be listened to get notified of any state mutitaion.

Every State Manger has it's own dispatcher which is used to emit actions that are responded with updated state.

```dart
//Accepted actions by this state
enum CounterActions {
  increment,
  decrement,
  error,
}

class CounterState extends StateManager<int, CounterActions> {
    //initial state as 0
  CounterState() : super(0);
}
```

**Reducer**

Reducer is a part of `StateManger` it contains the logic of state mutations depending upon the action. Reducer call the `updateState()` with new data and the all the listeners are notified about the new state.

```dart
class CounterState extends StateManager<int, CounterActions> {
  CounterState() : super(0);

  @override
  Future<void> reducer(action, props) async {
    switch (action) {
      case CounterActions.increment:
        updateState(cData + 1);
        break;
      case CounterActions.decrement:
        updateState(cData - 1);
        break;
      case CounterActions.error:
        updateStateWithError("Invalid action");
        break;
      default:
        throw Exception("Invalid action");
    }
  }
}
```

**Action**

Action can are specific instances that are emitted via the `.dispatch()` provided by the state manager.

Actions are also executed asychronously and sequentialy, Action get automatically queued until the previous one is running. This prevents your State from blocking the UI thread and also executing the actions in the right order.

```dart
final _counter = CounterState();

_counter.dispatch(CounterActions.increment);
_counter.dispatch(CounterActions.increment);
_counter.dispatch(CounterActions.increment);
```

**Middleware**

In Nano we have separate the `StateManger` from business logic that's not related to it's state mutation. API requests, Database queries should not be the part of the `StateManger` hence we have middleware.

Every time an Action is emitted, the `dispatch` checks if there are middlewares. If the middlewares exist, they will be executed first before the Action reaches the reucer.

Every middleware gets access a copy of current `state`, `action` and `props`.

`Props` data that's passed between middleware from top to bottom.

```dart
[
    GetDataMiddleware()
    CacheMiddleware()
]
```
In the above case, the `GetDataMiddleware()` will obtain the data from an api request and return the value. The returned value will be passed as `props` to the next middleware. `CacheMiddlware()` then get the data and cache it.

Defining a middleware
```dart
class LoggerMiddleWare extends Middleware {
  @override
  Future<Prop> run(state, action, props) async {
    print("LOGGER REPORT:");
    print("Action-> $action");
    print("State-> $state");
    print("Props-> $props");
    print("==END==");
    return Prop.success(props, allowNull: true);
  }
}
```

`pre` is just a short-name for middlewares.
```dart
_counter.dispatch(CounterActions.increment,pre: [LoggerMiddleWare()]);
```
The above action will first go to the `LoggerMiddleWare` and print the log then since there are no middleware it will goto the `reducer` which will identify the action and mutate the accordingly