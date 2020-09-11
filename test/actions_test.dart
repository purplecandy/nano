import 'package:flutter_test/flutter_test.dart';
import 'package:nano/src/exceptions.dart';
import 'mock_data/counter.dart';

main() {
  /// Validating the order of events emitted and the order of actions executed
  /// Synchronous is a forced way to dispatch the actions sequentially
  /// Asynchronous is another way of sequentially dispatching but allowing the operations to happen asychronously
  /// In the operation the order should remain the samin
  group("Action Execution Test", () {
    test("Synchronous Execution", () async {
      final counter = CounterStore();
      expect(counter.rawStream, emitsInOrder([0, 5, 15, 10]));
      counter.stream.listen((event) => print(event));
      await setRef(payload: CounterParam(counter, 5, 200)).run();
      await setRef(payload: CounterParam(counter, 15, 50)).run();
      await setRef(payload: CounterParam(counter, 10, 100)).run();
    });

    test("Asynchronous Dependent Execution", () async {
      final counter = CounterStore();
      expect(counter.rawStream, emitsInOrder([0, 5, 15, 10]));
      counter.stream.listen((event) => print(event));
      var action = setRef(payload: CounterParam(counter, 5, 200))..run();
      action =
          setRef(payload: CounterParam(counter, 15, 50), waitFor: [action.id])
            ..run();
      action =
          setRef(payload: CounterParam(counter, 10, 100), waitFor: [action.id])
            ..run();
    });

    test("Failed Dependency Execution", () async {
      final counter = CounterStore();
      bool failed = false;
      expect(
        counter.rawStream,
        emitsInOrder([0, 5]),
      );
      counter.stream.listen((event) => print(event));
      var action = setRef(payload: CounterParam(counter, 5, 200))..run();
      action = setRef(
          payload: CounterParam(counter, null, 200), waitFor: [action.id])
        ..run();
      action = setRef(
        payload: CounterParam(counter, 10, 100),
        onError: (e) {
          if (e is IncompleteDependency) failed = true;
          return;
        },
        waitFor: [action.id],
      )..run();
      await Future.delayed(Duration(milliseconds: 300));
      expect(failed, true);
    });
  });
}
