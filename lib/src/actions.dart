import 'dart:async';

import 'package:meta/meta.dart';
import 'package:nano/nano.dart';

typedef Future<K> ActionBody<T, K>(T payload);

class Mutation {
  final Store store;
  final dynamic type;
  Mutation(this.store, this.type);
}

typedef List<Mutation> ActionMutation<T extends Store, TT, K>(
    K response, TT payload);

typedef List<Store> ProxyStores<T>(T payload);

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
  final ProxyStores<T> proxyStores;
  Action(this._body,
      {@required this.payload,
      @required this.mutations,
      this.waitFor,
      this.proxyStores,
      this.hasProxyMutation});

  Future<List<Mutation>> call() async {
    assert(mutations != null);
    // Result of the computation
    var result;
    if (_body != null) result = await Future.microtask(() => _body(payload));
    final muts = mutations(result, payload);
    if (!hasProxyMutation && muts.isEmpty)
      throw Exception("Action has no mutations");
    return muts;
  }

  List<Store> getProxyStores() => proxyStores(payload);

  Future<void> proxyRun() async {
    assert(body != null);
    assert(proxyStores(payload) != null &&
        proxyStores(payload)?.isNotEmpty == true);
    await Future.microtask(() => _body(payload));
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

/// ActionRef will return a copy of Action which can be passed to the dispatcher to mutate changes
class ProxyActionRef<T, K> implements Function {
  ActionBody<T, K> _body;
  final List<Store> Function(T payload) proxyStores;
  final bool hasProxyMutation = true;
  ProxyActionRef(
    this._body, {
    @required this.proxyStores,
  });

  Action<T, K> call(
    T payload, {
    List<ActionId> waitFor,
  }) {
    assert(_body != null);
    return Action<T, K>(
      _body,
      mutations: null,
      payload: payload,
      waitFor: waitFor,
      hasProxyMutation: hasProxyMutation,
      proxyStores: proxyStores,
    );
  }
}
