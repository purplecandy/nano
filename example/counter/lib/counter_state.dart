import 'dart:async';

import 'package:nano/nano.dart';

enum CounterActions {
  increment,
  decrement,
  error,
}

class CounterState extends StateManager<dynamic, int, dynamic> {
  CounterState() : super(state: dynamic, object: 0);

  @override
  Future<void> reducer(action, props) async {
    switch (action) {
      case CounterActions.increment:
        updateState(null, cData + 1);
        break;
      case CounterActions.decrement:
        updateState(null, cData - 1);
        break;
      case CounterActions.error:
        updateStateWithError("Invalid action");
        break;
      default:
        throw Exception("Invalid action");
    }
  }
}
