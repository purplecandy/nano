# Actions

## Overview

Actions are functions, their job is to perform a task. The key difference between a normal function and an `Action` is that once an action is completed it returns a list of mutations. Then these mutations are sent to their respective stores which may or may not cause change in the state.

Action do the **How** part of obtaining the data, it can be from a database, an api call, a file or anything. Once the data is obtained they are converted to mutations.

Therefore, in general we call `Action` causes changes but it's important to understand that Actions play a bigger role than just mutating state.

### ActionRef

ActionRef or ActionReference is where you define your actions but do not create it. It's only a refernce to your action.

```dart
final setRef = ActionRef<CounterParam, void>(
  body: (payload) async {
    await Future.delayed(Duration(milliseconds: payload.seconds));
  },
  mutations: (result, payload) =>
      [Mutation(payload.store, CountMutation(payload.count))],
);
```
`setRef` above is refernce we can obtain it anywhere. Generally it's better to define all your action refernce in a class as static values.

Whenever we want to create an Action we will call the action reference

```dart
//CounterParam is the required payload here
final action = setRef(CounterParam());
```

But the actions still hasn't been executed, the `Dispatcher` knows that we have created an action but we haven't requested the dispatcher to execute it.

If we want to execute our action we will call the `run()`

```dart
action.run()
```