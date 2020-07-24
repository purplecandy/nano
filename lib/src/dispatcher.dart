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

  ActionId _generateToken() => ActionId(_prefix + (_lastId++).toString());

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

  ActionId add(Action action) {
    final actionId = _generateToken();
    _actions[actionId] = action;
    _execute(actionId);
    return actionId;
  }

  Future<void> _execute(ActionId id) async {
    if (_actions.containsKey(id)) {
      final action = _actions[id];
      if (action.waitFor == null || action.waitFor?.isEmpty == true) {
        final mutations = await _actions[id]();

        for (var mutation in mutations) {
          if (action.hasProxyMutation)
            mutation.store.setLastAction(LastAction(id, mutation.type));
          else
            dispatch(mutation.store, mutation.type);
        }
        _actions.remove(id);
        if (!action.hasProxyMutation) {
          _isCompleted[id] = true;
          _controller.add(_isCompleted);
        }
      } else {
        _waiting.add(_Waiting(id, action));
      }
    }
  }

  bool verify(ActionId id, Mutation mutation) {
    if (_proxyVerification.containsKey(id)) {
      return mutation == _proxyVerification[id];
    }
    return false;
  }
}

/// Create a new actions to be dispatched
ActionId dAdd(Action action) => Dispatcher.instance.add(action);

/// Get the Id of the next possible Action
ActionId dnextId() => Dispatcher.instance.nextId();

/// Verify if an action completed successfully
// bool dVerify(ActionId id) => Dispatcher.instance.verify(id);
