import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nano/nano.dart';
import 'package:nano/src/utils.dart';
import 'package:rxdart/rxdart.dart';
export 'package:rxdart/transformers.dart';
import 'package:rxdart/subjects.dart';
import 'package:meta/meta.dart';
import 'utils.dart';
import 'middleware.dart';
import 'state_snapshot.dart';
part 'state_utils.dart';

/// Author: Nadeem Siddique
///

typedef Dispatch<A> = void Function(
  A action, {
  Prop initialProps,
  void Function() onDone,
  void Function() onSuccess,
  void Function() onStop,
  void Function(Object error, StackTrace stack) onError,
});

typedef ActionWorker<A> = Function(Dispatch<A> put);

class LastAction {
  final ActionId id;
  final dynamic mutationType;
  LastAction(this.id, this.mutationType);
}

class ModifiedBehaviorSubject<T> extends Subject<T> implements ValueStream<T> {
  final BehaviorSubject<T> _subject;
  T _cachedValue;
  bool _hasError;

  factory ModifiedBehaviorSubject({
    void Function() onListen,
    void Function() onCancel,
    bool sync = false,
  }) {
    return ModifiedBehaviorSubject._(
        BehaviorSubject<T>(onListen: onListen, onCancel: onCancel, sync: sync));
  }

  factory ModifiedBehaviorSubject.seeded(
    T value, {
    void Function() onListen,
    void Function() onCancel,
    bool sync = false,
  }) {
    return ModifiedBehaviorSubject._(BehaviorSubject<T>.seeded(value,
        onListen: onListen, onCancel: onCancel, sync: sync));
  }

  ModifiedBehaviorSubject._(this._subject) : super(_subject, _subject) {
    _cachedValue = _subject.value;
  }

  @override
  void onAdd(T event) {
    _hasError = false;
    _cachedValue = event;
  }

  @override
  void onAddError(Object error, [StackTrace stackTrace]) {
    _hasError = true;
  }

  /// A boolean that return true if the last event emitted was an error
  bool get hasError => _hasError;

  @override
  bool get hasValue => _subject.hasValue;

  get sub => _subject;

  @override
  T get value => _subject.value;

  /// Returns the last cached value emitted
  T get cachedValue => _cachedValue;
}

abstract class Store<T, A> {
  final _defaultMiddlewares = List<Middleware>();
  final _watchers = <A, List<ActionWorker<A>>>{};
  final _queue = _ActionQueue();

  ActionId _lastAction;

  ActionId get lastAction => _lastAction;

  /// Controller that manges the actual data events
  ModifiedBehaviorSubject<StateSnapshot<T>> _controller;

  /// Controller that only manges the error events
  // PublishSubject<StateSnapshot<T>> _errorController;

  /// A publishSubject doesn't hold values hence a store to save the last error
  Object _lastEmittedError;
  Store([T state]) {
    // _errorController = PublishSubject<StateSnapshot<T>>();
    if (setInitialState)
      _controller = ModifiedBehaviorSubject<StateSnapshot<T>>.seeded(
          _initialState(state));
    else
      _controller = ModifiedBehaviorSubject<StateSnapshot<T>>();
  }

  bool get setInitialState => true;

  StateSnapshot<T> _initialState(T object) => StateSnapshot<T>(object, null);

  /// Current state
  StateSnapshot<T> get state => _lastEmittedError == null
      ? StateSnapshot(_controller.value?.data, null)
      : StateSnapshot(null, _lastEmittedError);

  ///Controller of the event stream
  ModifiedBehaviorSubject<StateSnapshot<T>> get controller => _controller;

  ///Stream that recieves both events and errors as data
  // Stream<StateSnapshot<T>> get _mergedStream =>
  //     _controller.stream.mergeWith([_errorController.stream]);

  Stream<StateSnapshot<T>> get stream => _controller.stream;
  // Stream<StateSnapshot<T>> get stream =>
  //     _mergedStream.transform(StreamTransformer.fromHandlers(
  //       handleData: (data, sink) => sink.add(state),
  //       handleError: (error, stackTrace, sink) => sink.addError(state),
  //     ));

  /// It returns a stream of `T` insted of [StateSnapshot]
  ///
  /// Makes tests easier to write
  Stream<T> get rawStream => stream.transform(StreamTransformer.fromHandlers(
      handleData: (snapshot, sink) => sink.add(snapshot.data),
      handleError: (error, stackTrace, sink) =>
          sink.addError((error as StateSnapshot).error)));

  /// Last emitted cached data
  T get cData => _controller.cachedValue.data;

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
    _controller.addError(StateSnapshot<T>(null, error));
    // _errorController.addError(StateSnapshot<T>(null, _lastEmittedError));
  }

  void dispose() {
    _controller.close();
    // _errorController.close();
    _queue.clear();
    _watchers.clear();
    _defaultMiddlewares.clear();
  }

  void setLastAction(ActionId last) => _lastAction = last;

  void reducer(A mutation);

  void _internalDispatch(_QueuedAction qa) {
    reducer(qa.mutationType);
    _notifyWorkers(qa.mutationType);
    // try {
    //   /// Props are values that are passed between middlewares and actions
    //   var props = qa.initialProps;
    //   final combined = List<Middleware>()
    //     ..addAll(_defaultMiddlewares)
    //     ..addAll(qa.pre ?? []);
    //   for (var middleware in combined) {
    //     // final resp = await compute(threadedExecution,
    //     //     MutliThreadArgs(middleware, state, qa.actionType, props));
    //     final resp = await middleware.run(state, qa.actionType, props);

    //     /// Reply of status unkown will cause an exception,
    //     /// unkown can will repsent situations that are considerend as traps
    //     /// this is abost the state update and [onError] will be called
    //     if (resp.isTerminated) {
    //       throw ActionTerminatedException(
    //           "Action termination requested by middleware: ${middleware.runtimeType}");
    //     } else {
    //       props = resp;
    //     }
    //   }
    //   await reducer(qa.actionType, props);
    //   qa.onSuccess?.call();
    //   _notifyWorkers(qa.actionType);
    // } on ActionTerminatedException catch (e) {
    //   print(e);
    //   qa.onStop?.call();
    // } catch (e, stack) {
    //   print("An exception occured when executing the action: ${qa.actionType}");
    //   qa.onError?.call(e, stack);
    // } finally {
    //   qa.onDone?.call();
    // }
  }

  /// Dispatch Actions which will mutate the state
  void dispatch(
    A mutation,
    //    {
    //   Prop initialProps,

    //   /// When the action is completed
    //   void Function() onDone,

    //   /// When the action is successfully completed
    //   void Function() onSuccess,

    //   /// When a middleware requests to terminate the action
    //   void Function() onStop,

    //   /// When the action fails to complete
    //   ///
    //   /// You can also force execute onError from a middleware by returning a `Status.unknown`
    //   void Function(Object error, StackTrace stack) onError,

    //   /// Middleware that will be called before the action is processed
    //   List<Middleware> pre,
    // }
  ) {
    _queue.enqueue(
      _QueuedAction<A>(
        mutationType: mutation,
        // initialProps: initialProps,
        // onDone: onDone,
        // onSuccess: onSuccess,
        // onError: onError,
        // pre: pre,
        // onStop: onStop,
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

dispatch(dynamic store, dynamic type) {
  if (store is Store)
    store.dispatch(type);
  else
    throw Exception("Invalid store");
}
