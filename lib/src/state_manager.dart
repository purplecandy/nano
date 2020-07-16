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
  Prop initialProps,
  void Function() onDone,
  void Function() onSuccess,
  void Function() onStop,
  void Function(Object error, StackTrace stack) onError,
  List<Middleware> pre,
});

typedef ActionWorker<A> = Function(Dispatcher<A> put);

abstract class StateManager<T, A> {
  final _defaultMiddlewares = List<Middleware>();
  final _watchers = <A, List<ActionWorker<A>>>{};
  final _queue = _ActionQueue();

  /// Controller that manges the actual data events
  BehaviorSubject<StateSnapshot<T>> _controller;

  /// Controller that only manges the error events
  PublishSubject<StateSnapshot<T>> _errorController;

  /// A publishSubject doesn't hold values hence a store to save the last error
  Object _lastEmittedError;
  StateManager(T state)
  // : assert(state != null)
  {
    _errorController = PublishSubject<StateSnapshot<T>>();
    _controller =
        BehaviorSubject<StateSnapshot<T>>.seeded(_initialState(state));
  }

  StateSnapshot<T> _initialState(T object) => StateSnapshot<T>(object, null);

  /// Current state
  StateSnapshot<T> get state => _lastEmittedError == null
      ? StateSnapshot(_controller.value.data, null)
      : StateSnapshot(null, _lastEmittedError);

  ///Controller of the event stream
  BehaviorSubject<StateSnapshot<T>> get controller => _controller;

  ///Stream that recieves both events and errors as data
  Stream<StateSnapshot<T>> get _mergedStream =>
      _controller.stream.mergeWith([_errorController.stream]);

  Stream<StateSnapshot<T>> get stream =>
      _mergedStream.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) => sink.add(state),
        handleError: (error, stackTrace, sink) => sink.addError(state),
      ));

  /// It returns a stream of `T` insted of [StateSnapshot]
  ///
  /// Makes tests easier to write
  Stream<T> get rawStream => stream.transform(StreamTransformer.fromHandlers(
      handleData: (snapshot, sink) => sink.add(snapshot.data),
      handleError: (error, stackTrace, sink) =>
          sink.addError((error as StateSnapshot).error)));

  /// Returns the [StateSnapshot.data] from last emitted state.
  ///
  /// It will not be overridden by an error
  T get cData => _controller.value.data;

  /// Emit a new state without error
  @protected
  void updateState(T data) {
    assert(data != null);
    _lastEmittedError = null;
    _controller.add(StateSnapshot<T>(data, _lastEmittedError));
  }

  /// Emit a state with error
  @protected
  void updateStateWithError(Object error) {
    assert(error != null);
    _lastEmittedError = error;
    _errorController.addError(StateSnapshot<T>(null, _lastEmittedError));
  }

  void dispose() {
    _controller.close();
    _errorController.close();
    _queue.clear();
    _watchers.clear();
    _defaultMiddlewares.clear();
  }

  Future<void> reducer(A action, Prop props);

  Future<void> _internalDispatch(_QueuedAction qa) async {
    try {
      /// Props are values that are passed between middlewares and actions
      var props = qa.initialProps;
      final combined = List<Middleware>()
        ..addAll(_defaultMiddlewares)
        ..addAll(qa.pre ?? []);
      for (var middleware in combined) {
        // final resp = await compute(threadedExecution,
        //     MutliThreadArgs(middleware, state, qa.actionType, props));
        final resp = await middleware.run(state, qa.actionType, props);

        /// Reply of status unkown will cause an exception,
        /// unkown can will repsent situations that are considerend as traps
        /// this is abost the state update and [onError] will be called
        if (resp.isTerminated) {
          throw ActionTerminatedException(
              "Action termination requested by middleware: ${middleware.runtimeType}");
        } else {
          props = resp;
        }
      }
      await reducer(qa.actionType, props);
      qa.onSuccess?.call();
      _notifyWorkers(qa.actionType);
    } on ActionTerminatedException catch (e) {
      print(e);
      qa.onStop?.call();
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
    Prop initialProps,

    /// When the action is completed
    void Function() onDone,

    /// When the action is successfully completed
    void Function() onSuccess,

    /// When a middleware requests to terminate the action
    void Function() onStop,

    /// When the action fails to complete
    ///
    /// You can also force execute onError from a middleware by returning a `Status.unknown`
    void Function(Object error, StackTrace stack) onError,

    /// Middleware that will be called before the action is processed
    List<Middleware> pre,
  }) async {
    _queue.enqueue(
      _QueuedAction<A>(
        actionType: action,
        initialProps: initialProps,
        onDone: onDone,
        onSuccess: onSuccess,
        onError: onError,
        pre: pre,
        onStop: onStop,
      ),
      _internalDispatch,
    );
  }

  ///Sets a default middlewares that will be executed on every action
  void setDefaultMiddlewares(List<Middleware> middlewares) {
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
