import 'dart:async';
import 'package:nano/src/exceptions.dart';
import 'package:nano/src/state_manager.dart';
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

  /// Returns a unique ActionId
  ActionId getId() => ActionId(_generateToken());

  Stream<Map<ActionId, bool>> get onActionComplete => _stream;

  void _onChange(Map<ActionId, bool> event) async {
    if (_busy) return;
    _busy = true;
    for (int ii = 0; ii < _waiting.length; ii++) {
      final item = _waiting[ii];
      try {
        if (_checkActionsCompleted(item.action.waitFor, item.action.id)) {
          item.action.clear(item.id);
          _actions[item.id] = item.action;
          await _execute(item.id);
          _waiting.removeAt(ii);
          ii--;
        }
      } catch (e) {
        if (item.action.onError != null)
          item.action.onError(e);
        else
          print(e);
        _waiting.removeAt(ii);
        ii--;
      }
    }
    _busy = false;
  }

  bool _checkActionsCompleted(List<ActionId> waiting, ActionId id) {
    if (waiting == null || waiting.isEmpty) return true;
    int i = 0;
    for (var actionId in waiting) {
      if (_isCompleted.containsKey(actionId)) {
        if (_isCompleted[actionId])
          i++;
        else
          throw IncompleteDependency(
              "$id has an incomplete depedency on $actionId");
      }
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
      final currentStore = action.store;

      // If the action has dependency on other action.
      // Check if the dependecies have completed dispatching

      try {
        if (_checkActionsCompleted(action.waitFor, id)) {
          //proceed with normal execution

          final mutation = await action();
          dispatch(currentStore, mutation);
          action.onDone?.call();
          _isCompleted[id] = true;
          _controller.add(_isCompleted);
        } else {
          //Add it to the queue
          _waiting.add(_Waiting(id, action));
        }
      } catch (e, stack) {
        if (action.onError != null) {
          final error = action.onError.call(e);
          if (error != null) emitError(currentStore, error);
        } else {
          print(e);
          print(stack);
        }
        _isCompleted[id] = false;
        _controller.add(_isCompleted);
      } finally {
        _actions.remove(id);
      }
    }
  }
}
