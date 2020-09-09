import "package:nano/nano.dart";
import 'counter_store.dart';

final incrementRef = ActionRef<Null, String>(
  store: (_) => counterRef.store,
  mutation: (result, payload) => CounterActions.increment,
);

final decrementRef = ActionRef<Null, String>(
  store: (_) => counterRef.store,
  mutation: (result, payload) => CounterActions.decrement,
);
