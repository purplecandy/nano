import 'dart:async';
import 'package:meta/meta.dart';
import 'package:nano/nano.dart';

typedef Future<K> ActionBody<T, K>(T payload);
typedef dynamic ActionMutation<K, T>(K response, T payload);
typedef List<Store> ProxyStores<T>(T payload);

class Mutation {
  final Store store;
  final dynamic type;
  Mutation(this.store, this.type);
}

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
  final ActionMutation<K, T> mutation;
  final bool hasProxyMutation;
  final ProxyStores<T> proxyStores;
  final Object Function(Object error) onError;
  final void Function() onDone;
  final Store store;
  Action({
    @required this.id,
    this.body,
    this.payload,
    @required this.mutation,
    @required this.store,
    this.waitFor,
    this.proxyStores,
    this.hasProxyMutation,
    this.onError,
    this.onDone,
  })  : assert(id != null),
        assert(mutation != null),
        assert(store != null);

  Future call() async {
    K result;
    if (body != null) result = await Future.microtask(() => body(payload));
    final mut = mutation(result, payload);
    // if (!hasProxyMutation && muts.isEmpty)
    //   throw Exception("Action has no mutations");
    return mut;
  }

  @deprecated
  List<Store> getProxyStores() => proxyStores(payload);

  @deprecated
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

  ///Creates an `Action` without any reference for quickly dispatching certain mutation that doesn't require any `body` parameter
  factory Action.anonymous(
    Store store,
    dynamic mutation, {
    Object Function(Object error) onError,
    void Function() onDone,
    List<ActionId> waitFor,
  }) {
    return Action(
      id: Dispatcher.instance.getId(),
      mutation: mutation,
      store: store,
      onDone: onDone,
      onError: onError,
      waitFor: waitFor,
      body: null,
      payload: null,
    );
  }
}

/// ActionRef will return a copy of Action which can be passed to the dispatcher to mutate changes
class ActionRef<T, K> implements Function {
  final ActionBody<T, K> body;
  final ActionMutation<K, T> mutation;
  final Store Function(T payload) store;

  ActionRef({
    @required this.mutation,
    @required this.store,
    this.body,
  })  : assert(mutation != null),
        assert(store != null);

  Action<T, K> call({
    T payload,
    List<ActionId> waitFor,
    Object Function(Object error) onError,
    void Function() onDone,
  }) {
    return Action<T, K>(
      id: Dispatcher.instance.getId(),
      body: body,
      store: store(payload),
      mutation: mutation,
      payload: payload,
      waitFor: waitFor,
      onDone: onDone,
      onError: onError,
    );
  }
}

@deprecated

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
    // ignore: missing_required_param
    return Action<T, K>(
      id: Dispatcher.instance.getId(),
      body: _body,
      mutation: null,
      payload: payload,
      waitFor: waitFor,
      hasProxyMutation: hasProxyMutation,
      proxyStores: proxyStores,
    );
  }
}
