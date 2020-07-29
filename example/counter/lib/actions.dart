import "package:nano/nano.dart";
import 'counter_state.dart';

final incrementRef = ActionRef<CounterState, String>(
  body: (param) async => "S",
  mutations: (result, payload) => [Mutation(payload, CounterActions.increment)],
);

final decrementRef = ActionRef<CounterState, String>(
  mutations: (result, payload) => [Mutation(payload, CounterActions.decrement)],
);
