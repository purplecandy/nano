import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nano/nano.dart';
import 'package:rxdart/rxdart.dart';
// Testing events emitted by Stream

// Mock Store for creating stores
abstract class CounterMutations {}

class IncrementMutation extends CounterMutations {}

class DecrementMutation extends CounterMutations {}

class ErrorMutation extends CounterMutations {}

class CountMutation extends CounterMutations {
  final int count;
  CountMutation(this.count);
}

class CounterStore extends Store<int, CounterMutations> {
  CounterStore() : super(0);

  @override
  void reducer(action) {
    if (action is IncrementMutation) updateState(cData + 1);
    if (action is DecrementMutation) updateState(cData - 1);
    if (action is ErrorMutation) updateStateWithError("Invalid action");
    if (action is CountMutation) updateState(action.count);
  }
}

class CounterParam {
  final CounterStore store;
  final int count;
  final int seconds;
  CounterParam(this.store, this.count, this.seconds);
}

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

void addListener(CounterStore counter, int count, int dcount, int ecount) {
  int c = count;
  counter.stream.listen(
    (e) {
      print(e);
      expectAsync1((e) {
        verifyData(e, c);
        c++;
      }, count: dcount);
    },
    onError: (e) =>
        // print(e),
        expectAsync1((event) {
      verifyError(event);
    }, count: ecount),
  );
}

void verifyError(StateSnapshot<int> event) {
  expect(event.hasError, true);
  expect(event.hasData, false);
  expect(event.waiting, false);
  expect(event.data, null);
  expect(event.error, "Invalid action");
}

void verifyData(StateSnapshot<int> event, int count) {
  expect(event.hasError, false);
  expect(event.hasData, true);
  expect(event.waiting, false);
  expect(event.error, null);
  expect(event.data, count);
}

main() {
  group("Action Execution Test", () {
    test("Synchronous Execution", () async {
      final counter = CounterStore();
      expect(counter.rawStream, emitsInOrder([0, 5, 15, 10]));
      counter.stream.listen((event) => print(event));
      await setRef(CounterParam(counter, 5, 200)).run();
      await setRef(CounterParam(counter, 15, 50)).run();
      await setRef(CounterParam(counter, 10, 100)).run();
    });

    test("Asynchronous Execution", () async {
      final counter = CounterStore();
      expect(counter.rawStream, emitsInOrder([0, 5, 15, 10]));
      counter.stream.listen((event) => print(event));
      var action = setRef(CounterParam(counter, 5, 200))..run();
      action = setRef(CounterParam(counter, 15, 50), waitFor: [action.id])
        ..run();
      action = setRef(CounterParam(counter, 10, 100), waitFor: [action.id])
        ..run();
    });
  });
}
