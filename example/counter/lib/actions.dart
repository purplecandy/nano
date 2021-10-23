import "package:nano/nano.dart";
import 'counter_store.dart';

Stream<Mutation> incrementRef()async* {
  yield Mutation(counterRef.store, CounterActions.increment);
}

Stream<Mutation> decrementRef()async* {
  yield Mutation(counterRef.store, CounterActions.decrement);
}

// final incrementRef = ActionRef<Null, String>(
//   store: (_) => counterRef.store,
//   mutation: (result, payload) => CounterActions.increment,
// );

// final decrementRef = ActionRef<Null, String>(
//   store: (_) => counterRef.store,
//   mutation: (result, payload) => CounterActions.decrement,
// );
