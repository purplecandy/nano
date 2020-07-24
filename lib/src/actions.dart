import 'dart:async';

import 'package:meta/meta.dart';
import 'package:nano/nano.dart';

typedef Future<K> ActionBody<T, K>(T payload);

class Mutation<T extends StateManager> {
  final T store;
  final dynamic type;
  Mutation(this.store, this.type);
}

typedef List<Mutation<T>> ActionMutation<T extends StateManager, TT, K>(
    K response, TT payload);

class ActionId {
  String token;
  ActionId(this.token);

  @override
  String toString() => "Action - $token";
}

class Action<T, K> implements Function {
  ActionBody<T, K> _body;
  ActionBody<T, K> get body => _body;
  final List<ActionId> waitFor;
  final T payload;
  final ActionMutation<dynamic, T, K> mutations;
  final bool hasProxyMutation;
  Action(this._body,
      {@required this.payload,
      @required this.mutations,
      this.waitFor,
      this.hasProxyMutation});

  Future<List<Mutation<dynamic>>> call() async {
    assert(mutations != null);
    // Result of the computation
    var result;
    if (_body != null) result = await Future.microtask(() => _body(payload));
    final muts = mutations(result, payload);
    if (!hasProxyMutation && muts.isEmpty)
      throw Exception("Action has no mutations");
    return muts;
  }

  void clear(ActionId id) {
    assert(id != null);
    waitFor.clear();
  }
}

/// ActionRef will return a copy of Action which can be passed to the dispatcher to mutate changes
class ActionRef<T, K> implements Function {
  ActionBody<T, K> _body;
  final ActionMutation<dynamic, T, K> mutations;
  final bool hasProxyMutation;
  ActionRef(this._body,
      {@required this.mutations, this.hasProxyMutation = false});

  Action<T, K> call(
    T payload, {
    List<ActionId> waitFor,
  }) {
    assert(mutations != null);
    return Action<T, K>(_body,
        mutations: mutations,
        payload: payload,
        waitFor: waitFor,
        hasProxyMutation: hasProxyMutation);
  }
}
