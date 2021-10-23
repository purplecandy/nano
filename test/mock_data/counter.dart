import 'package:nano/nano.dart';

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
    print("Incoming $action");
    if (action is IncrementMutation) updateState(cData! + 1);
    if (action is DecrementMutation) updateState(cData! - 1);
    if (action is ErrorMutation) updateStateWithError("Invalid action");
    if (action is CountMutation) updateState(action.count);
  }
}

class CounterParam {
  final CounterStore store;
  final int? count;
  final int seconds;
  CounterParam(this.store, this.count, this.seconds);
}
//Actions

Stream<Mutation> setRef(CounterParam payload) async* {
  if (payload.count == null) throw Exception("Count value can't be null");
  await Future.delayed(Duration(milliseconds: payload.seconds));
  yield Mutation(payload.store, CountMutation(payload.count!));
}
