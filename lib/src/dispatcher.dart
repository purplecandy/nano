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
  Map<ActionId, Action> _actions = {};
  List<_Waiting> _waiting = [];
  Map<ActionId, bool> _isCompleted = {};
  Map<ActionId, dynamic> _proxyVerification = {};
  StreamController<Map<ActionId, bool>> _controller;
  Stream<Map<ActionId, bool>> _stream;
  static Dispatcher instance = Dispatcher._internal();
  factory Dispatcher() => instance;
  Dispatcher._internal() {
    _controller = StreamController<Map<ActionId, bool>>();
    _stream = _controller.stream.asBroadcastStream();
    _stream.listen(_onChange);
  }

  String _generateToken() => (_prefix + (_lastId++).toString());

  /// Returns the next id
  ActionId nextId() => ActionId(_prefix + (_lastId + 1).toString());

  Stream<Map<ActionId, bool>> get onActionComplete => _stream;

  void _onChange(Map<ActionId, bool> event) {
    for (int ii = 0; ii < _waiting.length; ii++) {
      int i = 0;
      final item = _waiting[ii];
      for (var actionId in item.action.waitFor) {
        if (_isCompleted.containsKey(actionId)) i++;
      }
      if (i == item.action.waitFor.length) {
        item.action.clear(item.id);
        _actions[item.id] = item.action;
        _execute(item.id);
        _waiting.removeAt(ii);
        ii--;
      }
    }
  }

  ActionId add(Action action,
      {void Function(Object error) onError, void Function() onDone}) {
    final token = _generateToken();
    final actionId = ActionId(token, onError: onError, onDone: onDone);
    _actions[actionId] = action;
    _execute(actionId);
    return actionId;
  }

  Future<void> _execute(ActionId id) async {
    if (_actions.containsKey(id)) {
      final action = _actions[id];
      if (action.waitFor == null || action.waitFor?.isEmpty == true) {
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
            id.onDone?.call();
          }
        } catch (e, stack) {
          print(e);
          print(stack);
          id.onError?.call(e);
        } finally {
          _actions.remove(id);
        }
      } else {
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
      id.onDone?.call();
    }
  }
}

/// Create a new actions to be dispatched
ActionId dAdd(Action action,
        {void Function(Object error) onError, void Function() onDone}) =>
    Dispatcher.instance.add(action, onDone: onDone, onError: onError);

/// Get the Id of the next possible Action
ActionId dnextId() => Dispatcher.instance.nextId();

/// Verify if an action completed successfully
// bool dVerify(ActionId id) => Dispatcher.instance.verify(id);
