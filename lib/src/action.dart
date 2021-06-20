import 'dart:async';
import 'dispatcher.dart';
import 'state_manager.dart';
import 'package:meta/meta.dart';

typedef Future<K> ActionBody<T, K>(T payload);

/// Unique id of every action
/// This is generated by the Dispatcher
/// It can also be obtained by `Dispatcher.instance.getId()`
class ActionId {
  final String token;
  ActionId(this.token);

  @override
  String toString() => "Action - $token";
}

class Mutation<T> {
  final Store store;
  final T type;
  Mutation(this.store, this.type);

  Type get typeOf => type.runtimeType;
}

typedef List<Mutation> ActionMutations<T, K>(K response, T payload);
typedef dynamic ActionMutation<K, T>(K response, T payload);
typedef List<Store> ProxyStores<T>(T payload);

/// Actions that are send to the Dispatcher and executed
/// which causes mutation on the specified store's state
class Action {
  /// You perform any async actions that are required for a mutation and yeild the mutation
  ///
  /// Since it's a stream multiple mutations can be emitted from a single action
  ///
  /// You can also call another action here by using `yield*` to emit all the events from the action
  ///
  /// Any unhandled exceptions will execute `onError()` if passed
  final Stream<Mutation> Function() body;

  /// A list of fallback mutations you want to send to as Error events
  ///
  /// 
  /// You're basically emitting state with erros, just a little quicker utilizing the same action
  /// ```dart
  /// void reducer(mutation){
  ///   updateStateWithError(mutation);
  /// }
  /// ```
  /// 
  /// Feel free to pass any object you want, error and data state are maintained seperately so you can emit errors anytime without worrying about losing your data
  final List<Mutation> Function(Object error) onError;

  /// Executed when the action has been successfully executed
  final void Function() onDone;
  final ActionId _id = Dispatcher.instance.getId();

  /// A list actions that you want to wait for them to be executed successfully before executing this action.
  /// If anyone of the action fails in then the action will not execute
  ///
  /// This can be used to achive consistency between shared stores, as this will ensure when it only execute if the depdencies have executed successfuly.
  final List<ActionId> waitFor;

  /// A unique id that represents a specific instance of an action
  ActionId get id => _id;
  Action(this.body, {this.onDone, this.onError, this.waitFor});
  void clear(ActionId id) {
    assert(id != null);
    waitFor.clear();
  }

  Future<void> run() async => await Dispatcher.instance.add(this);
}

/// ActionRef will return a copy of Action which can be passed to the dispatcher to mutate changes
class ActionRef<T, K> implements Function {
  final ActionBody<T, K> body;
  final ActionMutations<T, K> mutations;
  final bool hasProxyMutation;
  final Store Function(T payload) store;
  final ActionMutation<K, T> mutation;
  ActionRef({
    this.mutations,
    this.mutation,
    this.body,
    this.hasProxyMutation = false,
    this.store,
  });

  Action call(
      {T payload,
      List<ActionId> waitFor,
      List<Mutation> Function(Object error) onError,
      void Function() onDone}) {
    assert(mutations != null || (store != null && mutation != null));
    return Action(
      () async* {
        var result;
        if (body != null) result = await Future.microtask(() => body(payload));
        if (mutations != null) {
          final listOfMutations = mutations(result, payload);
          for (var mutation in listOfMutations) {
            yield mutation;
          }
        } else {
          final storeObject = store(payload);
          final mutationObject = mutation(result, payload);
          yield Mutation(storeObject, mutationObject);
        }
      },
      waitFor: waitFor,
      onDone: onDone,
      onError: onError,
    );
  }
}
