part of 'state_manager.dart';

class _QueuedAction<A> {
  final A mutationType;
  _QueuedAction({required this.mutationType});
}

class _ActionQueue<A> {
  final _queue = <_QueuedAction>[];
  bool _busy = false;

  /// Removes all actions from the queue
  void clear() => _queue.clear();
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  void enqueue(
      _QueuedAction<A> action, Function(_QueuedAction action) callback) {
    _queue.add(action);

    if (_busy == false) onChange(callback);
  }

  void _dequeue() => _queue.removeAt(0);

  void onChange(void Function(_QueuedAction action) cb) {
    if (_queue.isNotEmpty) {
      _busy = true;
      cb.call(_queue.first);
      _dequeue();
      onChange(cb);
    }
    _busy = false;
  }
}

class _MutliThreadArgs<T> {
  final T state;
  final dynamic action, props;
  final Middleware middleWare;
  const _MutliThreadArgs(this.middleWare, this.state, this.action, this.props);
}

Future<Prop> threadedExecution(_MutliThreadArgs args) async {
  return await args.middleWare.run(args.state, args.action, args.props);
}
