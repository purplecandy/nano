import 'dart:async';

import 'package:nano/nano.dart';

enum CounterActions {
  increment,
  decrement,
  error,
}

class CounterStore extends Store<int, CounterActions> {
  CounterStore() : super(0);

  @override
  Future<void> reducer(action) async {
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

final counterRef = Pool.instance.register(() => CounterStore());
