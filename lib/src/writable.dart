import 'dart:async';
import 'package:nano/nano.dart';

class Writable<T> {
  final _defaultMiddlewares = List<Middleware>();

  /// Controller that manges the actual data events
  ModifiedBehaviorSubject<StateSnapshot<T>> _controller;

  Object _lastEmittedError;
  Writable({T state, bool setInitialState = true}) {
    if (setInitialState)
      _controller = ModifiedBehaviorSubject<StateSnapshot<T>>.seeded(
          _initialState(state));
    else
      _controller = ModifiedBehaviorSubject<StateSnapshot<T>>();
  }

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
      handleData: (snapshot, sink) => sink.add(snapshot.data),
      handleError: (error, stackTrace, sink) =>
          sink.addError((error as StateSnapshot).error)));

  /// Last emitted cached data
  T get cData => _controller.cachedValue?.data;

  // Directly listen to the store's state changes
  StreamSubscription<StateSnapshot<T>> listen(
      void onData(StateSnapshot<T> value),
      {Function onError,
      void onDone(),
      bool cancelOnError}) {
    return controller.listen(
      onData,
      onDone: onDone,
      cancelOnError: cancelOnError,
      onError: onError,
    );
  }

  /// Emit a new state without error
  void add(T data) {
    assert(data != null);
    _lastEmittedError = null;
    _controller.add(StateSnapshot<T>(data, _lastEmittedError));
  }

  /// Emit a state with error
  void addError(Object error) {
    assert(error != null);
    _lastEmittedError = error;
    _controller.addError(StateSnapshot<T>(null, error));
  }

  void dispose() {
    _controller.close();
    _defaultMiddlewares.clear();
  }

  @deprecated

  ///Sets a default middlewares that will be executed on every action
  void setDefaultMiddlewares(List<Middleware> middlewares) {
    if (_defaultMiddlewares.isNotEmpty)
      throw Exception("Default middlewares can only be set once");
    else
      _defaultMiddlewares.addAll(middlewares);
  }
}
