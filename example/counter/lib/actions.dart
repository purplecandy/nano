import "package:nano/nano.dart";
import 'counter_state.dart';

final incrementRef = ActionRef<CounterStore, String>(
  mutation: (result, payload) => Mutation(payload, CounterActions.increment),
);

final decrementRef = ActionRef<CounterStore, String>(
  mutation: (result, payload) => Mutation(payload, CounterActions.decrement),
);
