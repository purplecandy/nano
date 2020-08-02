import 'dart:async';
import 'package:nano/nano.dart';
import 'package:nano/src/actions.dart';

class _Waiting {
  final ActionId id;
  final Action action;
  _Waiting(this.id, this.action);
}

class Dispatcher {
  final _prefix = "action_id_";
  int _lastId = 0;
  final Map<ActionId, Action> _actions = {};
  final List<_Waiting> _waiting = [];
  final Map<ActionId, bool> _isCompleted = {};
  final Map<ActionId, dynamic> _proxyVerification = {};
  StreamController<Map<ActionId, bool>> _controller;
  Stream<Map<ActionId, bool>> _stream;

  bool _busy = false;

  static Dispatcher instance = Dispatcher._internal();
  factory Dispatcher() => instance;
  Dispatcher._internal() {
    _controller = StreamController<Map<ActionId, bool>>();
    _stream = _controller.stream.asBroadcastStream();
    _stream.listen(_onChange);
  }

  String _generateToken() => (_prefix + (_lastId++).toString());

  ActionId getId() => ActionId(_generateToken());

  /// Returns the next id
  ActionId nextId() => ActionId(_prefix + (_lastId + 1).toString());

  Stream<Map<ActionId, bool>> get onActionComplete => _stream;

  void _onChange(Map<ActionId, bool> event) async {
    if (_busy) return;
    _busy = true;
    for (int ii = 0; ii < _waiting.length; ii++) {
      final item = _waiting[ii];
      if (_checkActionsCompleted(item.action.waitFor)) {
        item.action.clear(item.id);
        _actions[item.id] = item.action;
        await _execute(item.id);
        _waiting.removeAt(ii);
        ii--;
      }
    }
    _busy = false;
  }

  bool _checkActionsCompleted(List<ActionId> waiting) {
    if (waiting == null || waiting.isEmpty) return true;
    int i = 0;
    for (var actionId in waiting) {
      if (_isCompleted.containsKey(actionId)) i++;
    }
    return i == waiting.length;
  }

  Future<void> add(Action action) async {
    _actions[action.id] = action;
    await _execute(action.id);
  }

  Future<void> _execute(ActionId id) async {
    if (_actions.containsKey(id)) {
      final action = _actions[id];
      // If the action has dependency on other action.
      // Check if the dependecies have completed dispatching

      if (_checkActionsCompleted(action.waitFor)) {
        //proceed with normal execution
        try {
          if (action.hasProxyMutation) {
            // will be mutated by proxy stream
            for (var store in action.getProxyStores()) {
              store.setLastAction(id);
            }
            // this should cause change in the proxy stream
            _proxyVerification[id] = id;
            await action.proxyRun();
          } else {
            // will be mutated by dispatch
            final mutations = await _actions[id]();
            for (var mutation in mutations) {
              dispatch(mutation.store, mutation.type);
            }
            _isCompleted[id] = true;
            _controller.add(_isCompleted);
            action.onDone?.call();
          }
        } catch (e, stack) {
          print(e);
          print(stack);
          action.onError?.call(e);
        } finally {
          _actions.remove(id);
        }
      } else {
        //Add it to the queue
        _waiting.add(_Waiting(id, action));
      }
    }
  }

  bool verify(ActionId id, [Mutation mutation]) {
    return _proxyVerification.containsKey(id);
  }

  void completeProxyAction(ActionId id) {
    if (_proxyVerification.containsKey(id)) {
      _proxyVerification.remove(id);
      _isCompleted[id] = true;
      _controller.add(_isCompleted);
      //TODO: call on complete
    }
  }
}

/// Create a new actions to be dispatched
Future<void> dAdd(Action action) async => await Dispatcher.instance.add(action);

/// Get the Id of the next possible Action
ActionId dnextId() => Dispatcher.instance.nextId();

/// Verify if an action completed successfully
// bool dVerify(ActionId id) => Dispatcher.instance.verify(id);
