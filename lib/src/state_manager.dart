import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nano/src/utils.dart';
import 'package:rxdart/rxdart.dart';
export 'package:rxdart/transformers.dart';
import 'package:meta/meta.dart';
import 'utils.dart';
import 'middleware.dart';
import 'state_snapshot.dart';
part 'state_utils.dart';

/// Author: Nadeem Siddique
///

typedef Dispatcher<A> = void Function(
  A action, {
  dynamic initialProps,
  void Function() onDone,
  void Function() onSuccess,
  void Function(Object error, StackTrace stack) onError,
  List<MiddleWare> pre,
});

typedef ActionWorker<A> = Function(Dispatcher<A> put);

abstract class StateManager<S, T, A> {
  final _defaultMiddlewares = List<MiddleWare>();
  final _watchers = <A, List<ActionWorker<A>>>{};
  final _queue = _ActionQueue();

  /// Controller that manges the actual data events
  BehaviorSubject<StateSnapshot<S, T>> _controller;

  /// Controller that only manges the error events
  PublishSubject<StateSnapshot<S, T>> _errorController;

  /// A publishSubject doesn't hold values hence a store to save the last error
  Object _lastEmittedError;

  StateManager({S state, T object}) {
    //emit the error object with a null first
    _errorController = PublishSubject<StateSnapshot<S, T>>();
    _controller = BehaviorSubject<StateSnapshot<S, T>>();
    _controller = BehaviorSubject<StateSnapshot<S, T>>.seeded(
        _initialState(state, object));
  }

  ///Controller of the event stream
  BehaviorSubject<StateSnapshot<S, T>> get controller => _controller;

  ///Stream that recieves both events and errors
  ///
  ///You should always listen to this stream
  Stream<StateSnapshot<S, T>> get stream =>
      _controller.stream.mergeWith([_errorController.stream]);

  /// It returns a stream of `T` insted of [StateSnapshot]
  ///
  /// Makes tests easier to write
  Stream<T> get rawStream => stream
          .transform(StreamTransformer.fromHandlers(handleData: (state, sink) {
        if (state.hasData)
          sink.add(state.data);
        else
          sink.add(state.error);
      }));

  /// Returns the [StateSnapshot.data] from last emitted state.
  ///
  /// It will not be overridden by an error
  T get cData => _controller.value.data;

  /// Returns the `StateSnapshot.status` from last emitted state without errors
  ///
  /// It will not be overridden by an error
  S get cStatus => _controller.value.status;

  /// Current state
  StateSnapshot<S, T> get state => _lastEmittedError == null
      ? StateSnapshot(_controller.value.status, _controller.value.data, null)
      : StateSnapshot(null, null, _lastEmittedError);

  /// Emit a new state without error
  @protected
  void updateState(S state, T data) {
    assert(data != null);
    _lastEmittedError = null;
    _controller.add(StateSnapshot<S, T>(state, data, _lastEmittedError));
  }

  /// Emit a state with error
  @protected
  void updateStateWithError(Object error) {
    assert(error != null);
    _lastEmittedError = error;
    _errorController
        .addError(StateSnapshot<S, T>(null, null, _lastEmittedError));
  }

  StateSnapshot<S, T> _initialState(S state, T object) =>
      StateSnapshot<S, T>(state, object, null);

  void dispose() {
    _controller.close();
    _errorController.close();
    _queue.clear();
    _watchers.clear();
    _defaultMiddlewares.clear();
  }

  Future<void> reducer(A action, Reply props);

  Future<void> _internalDispatch(_QueuedAction qa) async {
    try {
      /// Props are values that are passed between middlewares and actions
      var props = qa.initialProps;
      final combined = List<MiddleWare>()
        ..addAll(_defaultMiddlewares)
        ..addAll(qa.pre ?? []);
      for (var middleware in combined) {
        // final resp = await compute(threadedExecution,
        //     MutliThreadArgs(middleware, state, qa.actionType, props));
        final resp = await middleware.run(state, qa.actionType, props);

        /// Reply of status unkown will cause an exception,
        /// unkown can will repsent situations that are considerend as traps
        /// this is abost the state update and [onError] will be called
        if (resp.isUnknown) {
          print("Middleware failed at: ${middleware.runtimeType}");
          throw Exception(resp.error);
        } else {
          props = resp;
        }
      }
      await reducer(qa.actionType, props);
      qa.onSuccess?.call();
      _notifyWorkers(qa.actionType);
    } catch (e, stack) {
      print("An exception occured when executing the action: ${qa.actionType}");
      qa.onError?.call(e, stack);
    } finally {
      qa.onDone?.call();
    }
  }

  /// Dispatch Actions which will mutate the state
  void dispatch(
    A action, {
    dynamic initialProps,

    /// When the action is completed
    void Function() onDone,

    /// When the action is successfully completed
    void Function() onSuccess,

    /// When the action fails to complete
    ///
    /// You can also force execute onError from a middleware by returning a `Status.unknown`
    void Function(Object error, StackTrace stack) onError,

    /// Middleware that will be called before the action is processed
    List<MiddleWare> pre,
  }) async {
    _queue.enqueue(
      _QueuedAction<A>(
          actionType: action,
          initialProps: initialProps,
          onDone: onDone,
          onSuccess: onSuccess,
          onError: onError,
          pre: pre),
      _internalDispatch,
    );
  }

  ///Sets a default middlewares that will be executed on every action
  void setDefaultMiddlewares(List<MiddleWare> middlewares) {
    if (_defaultMiddlewares.isNotEmpty)
      throw Exception("Default middlewares can only be set once");
    else
      _defaultMiddlewares.addAll(middlewares);
  }

  /// Add a listerner that executes everytime the specified action is executed
  void addWorker(A action, ActionWorker<A> worker) {
    if (_watchers.containsKey(action))
      _watchers[action].add(worker);
    else
      _watchers[action] = <ActionWorker<A>>[worker];
  }

  /// Executes all workers attached to the specified action
  void _notifyWorkers(A action) {
    if (_watchers.containsKey(action))
      for (var worker in _watchers[action]) {
        worker.call(dispatch);
      }
  }

  /// Returns `true` if a worker is removed
  bool removeWorker(A action, ActionWorker worker) {
    if (!_watchers.containsKey(action)) return false;
    _watchers[action].removeWhere((element) => element == worker);
    return true;
  }
}
