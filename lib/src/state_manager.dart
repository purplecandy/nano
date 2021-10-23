import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nano/nano.dart';
import 'package:nano/src/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:meta/meta.dart';
import 'utils.dart';
import 'middleware.dart';
import 'state_snapshot.dart';
part 'state_utils.dart';

/// Worker are callback that do when the Store state has met the specified condition
/// Advantanges of workers over just listening the store for changes is that it gives you a `limit` that specifies
/// the number of times it needs to be called and after that it automatically get's removed
///
/// Also Worker provides a little nicer syntax, it's totally depedening upon the use case whether you want to use a worker or just listen to stream.
class Worker<T> {
  /// When to execute the worker, currently it only checks condition for new values, the current value will be skipped.
  final bool Function(T data) condition;

  /// The task that needs to performed when the condition is met
  final void Function() callback;

  /// Number of times it needs to be called
  ///
  /// If not specified it will run infintely and you will have to explicitly remove it
  final int? limit;
  int called = 0;
  Worker(this.condition, this.callback, {this.limit})
      : assert(callback != null),
        assert(condition != null);

  bool get _completed => limit == null ? false : limit == called;

  void execute(T data) {
    if (condition(data)) {
      callback();
      called++;
    }
  }
}

// class LastAction {
//   final ActionId id;
//   final dynamic mutationType;
//   LastAction(this.id, this.mutationType);
// }

/// BehaviorSubject that retains the last successfull data on receiving an error.
class ModifiedBehaviorSubject<T> extends Subject<T> implements ValueStream<T> {
  final BehaviorSubject<T> _subject;
  late T _cachedValue;
  late bool _hasError;

  factory ModifiedBehaviorSubject({
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    return ModifiedBehaviorSubject._(
        BehaviorSubject<T>(onListen: onListen, onCancel: onCancel, sync: sync));
  }

  factory ModifiedBehaviorSubject.seeded(
    T value, {
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    return ModifiedBehaviorSubject._(BehaviorSubject<T>.seeded(value,
        onListen: onListen, onCancel: onCancel, sync: sync));
  }

  ModifiedBehaviorSubject._(this._subject) : super(_subject, _subject) {
    _cachedValue = _subject.value;
  }

  @protected
  @override
  void onAdd(T event) {
    _hasError = false;
    _cachedValue = event;
  }

  @protected
  @override
  void onAddError(Object error, [StackTrace? stackTrace]) {
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
  

  @override
  T? get valueOrNull => _subject.valueOrNull;

  @override
  Object get error => _subject.error;

  @override
  StackTrace? get stackTrace => _subject.stackTrace;

  @override
  Object? get errorOrNull => _subject.errorOrNull;
}

abstract class Store<T, A> {
  final _defaultMiddlewares = <Middleware>[];
  final _workers = <Worker>[];
  final _queue = _ActionQueue();

  // ActionId _lastAction;

  // ActionId get lastAction => _lastAction;

  /// Controller that manges the actual data events
  late ModifiedBehaviorSubject<StateSnapshot<T>> _controller;

  /// A publishSubject doesn't hold values hence a store to save the last error
  Object? _lastEmittedError;
  Store([T? state]) {
    // _errorController = PublishSubject<StateSnapshot<T>>();
    if (setInitialState && state != null)
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

  Stream<StateSnapshot<T>> get stream => _controller.stream;

  /// It returns a stream of `T` insted of [StateSnapshot]
  ///
  /// Makes tests easier to write
  Stream<T> get rawStream => stream.transform(StreamTransformer.fromHandlers(
      handleData: (snapshot, sink) => sink.add(snapshot.data!),
      handleError: (error, stackTrace, sink) => sink.addError((error as StateSnapshot).error!)));

  /// Last emitted cached data
  T? get cData => _controller.cachedValue.data;

  // Directly listen to the store's state changes
  StreamSubscription<StateSnapshot<T>> listen(
      void onData(StateSnapshot<T> value),
      {Function? onError,
      void onDone()?,
      bool? cancelOnError}) {
    return controller.listen(
      onData,
      onDone: onDone,
      cancelOnError: cancelOnError,
      onError: onError,
    );
  }

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
  }

  void dispose() {
    _controller.close();
    _queue.clear();
    _workers.clear();
    _defaultMiddlewares.clear();
  }

  // void setLastAction(ActionId last) => _lastAction = last;

  void reducer(A mutation);

  void _internalDispatch(_QueuedAction qa) {
    reducer(qa.mutationType);
    _notifyWorkers();
  }

  /// This will made private every change has to go through Dispatcher as action.
  /// But I'm still figuring out some good usecase for this
  /// Dispatch Actions which will mutate the state
  void _dispatch(
    A mutation,
  ) {
    _queue.enqueue(
      _QueuedAction<A>(mutationType: mutation),
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
  void addWorker(Worker worker) => _workers.add(worker);

  /// Executes all workers attached to the specified mutation
  void _notifyWorkers() {
    for (var i = 0; i < _workers.length; i++) {
      _workers[i].execute(cData);
      if (_workers[i]._completed) _workers.removeAt(i);
    }
  }

  /// Returns `true` if a worker is removed
  void removeWorker(Worker worker) {
    _workers.removeWhere((element) => element == worker);
  }

  void _emitError(Object error) => updateStateWithError(error);
}

sendMutation(Store store, dynamic type) => store._dispatch(type);

emitError(Store store, Object error) => store._emitError(error);
