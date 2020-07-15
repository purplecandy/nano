part of 'state_manager.dart';

class _QueuedAction<A> {
  final A actionType;
  final dynamic initialProps;
  final void Function() onDone, onSuccess;
  final void Function(Object error, StackTrace stack) onError;
  final List<MiddleWare> pre;
  _QueuedAction(
      {@required this.actionType,
      @required this.initialProps,
      @required this.onDone,
      @required this.onSuccess,
      @required this.onError,
      @required this.pre});
}

class _ActionQueue<A> {
  final _queue = List<_QueuedAction>();
  bool _busy = false;

  /// Removes all actions from the queue
  get clear => _queue.clear();
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  void enqueue(_QueuedAction<A> action,
      Future<void> Function(_QueuedAction action) callback) {
    _queue.add(action);

    if (_busy == false) onChange(callback);
  }

  void _dequeue() => _queue.removeAt(0);

  void onChange(Future<void> Function(_QueuedAction action) cb) async {
    if (_queue.isNotEmpty) {
      _busy = true;
      await cb?.call(_queue.first);
      _dequeue();
      onChange(cb);
    }
    _busy = false;
  }
}

class _MutliThreadArgs<T> {
  final T state;
  final dynamic action, props;
  final MiddleWare middleWare;
  const _MutliThreadArgs(this.middleWare, this.state, this.action, this.props);
}

Future<Reply> threadedExecution(_MutliThreadArgs args) async {
  return await args.middleWare.run(args.state, args.action, args.props);
}
