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
  final ActionBody<T, K> body;
  final ActionId id;
  final List<ActionId> waitFor;
  final T payload;
  final ActionMutation<dynamic, T, K> mutations;
  final bool hasProxyMutation;
  final ProxyStores<T> proxyStores;
  final void Function(Object error) onError;
  final void Function() onDone;
  Action({
    @required this.id,
    @required this.body,
    @required this.payload,
    @required this.mutations,
    this.waitFor,
    this.proxyStores,
    this.hasProxyMutation,
    this.onError,
    this.onDone,
  });

  Future<List<Mutation>> call() async {
    assert(mutations != null);
    // Result of the computation
    var result;
    if (body != null) result = await Future.microtask(() => body(payload));
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
    await Future.microtask(() => body(payload));
  }

  Future<void> run() async => await Dispatcher.instance.add(this);

  void clear(ActionId id) {
    assert(id != null);
    waitFor.clear();
  }
}

/// ActionRef will return a copy of Action which can be passed to the dispatcher to mutate changes
class ActionRef<T, K> implements Function {
  final ActionBody<T, K> body;
  final ActionMutation<dynamic, T, K> mutations;
  final bool hasProxyMutation;
  ActionRef(
      {@required this.mutations, this.body, this.hasProxyMutation = false});

  Action<T, K> call(T payload,
      {List<ActionId> waitFor,
      void Function(Object error) onError,
      void Function() onDone}) {
    assert(mutations != null);
    return Action<T, K>(
      id: Dispatcher.instance.getId(),
      body: body,
      mutations: mutations,
      payload: payload,
      waitFor: waitFor,
      hasProxyMutation: hasProxyMutation,
      onDone: onDone,
      onError: onError,
    );
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
      id: Dispatcher.instance.getId(),
      body: _body,
      mutations: null,
      payload: payload,
      waitFor: waitFor,
      hasProxyMutation: hasProxyMutation,
      proxyStores: proxyStores,
    );
  }
}
