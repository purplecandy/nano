import 'package:flutter/material.dart';
import 'dart:async';
import 'state_snapshot.dart';

typedef bool BuilderCondition<S, T>(StateSnapshot state);
typedef Widget SnapBuilder<S, T>(
    BuildContext context, StateSnapshot<S, T> event);

class StateBuilder<S, T> extends StatefulWidget {
  final StateSnapshot<S, T> initialState;
  final Stream<StateSnapshot<S, T>> stream;
  final BuilderCondition<S, T> rebuildOnly;
  final SnapBuilder<S, T> builder;
  final Widget Function(BuildContext context, T data) onData;
  final Widget Function(BuildContext context, Object error) onError;
  const StateBuilder(
      {Key key,
      @required this.initialState,
      @required this.stream,
      this.rebuildOnly,
      this.onData,
      this.onError,
      this.builder})
      : assert(!(builder != null && (onData != null || onError != null))),
        assert(initialState != null),
        assert(stream != null),
        super(key: key);
  // true &&
  @override
  _StateBuilderState createState() => _StateBuilderState<S, T>();
}

class _StateBuilderState<S, T> extends State<StateBuilder<S, T>> {
  Stream<StateSnapshot<S, T>> get stream => widget.stream;
  StreamSubscription _subscription;
  StateSnapshot<S, T> _lastValue;
  bool _hasError = false;

  void _initialize() {
    _hasError = widget.initialState.hasError;
    _lastValue = widget.initialState;
    _subscription = stream.listen(
        (event) {
          if (widget.rebuildOnly != null) {
            if (widget.rebuildOnly.call(event)) {
              _hasError = false;
              _lastValue = event;
            }
          } else {
            _hasError = false;
            _lastValue = event;
          }
          setState(() {});
        },
        onDone: () {},
        onError: (snap) {
          setState(() {
            _hasError = true;
            _lastValue = snap;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    if (stream != null) _initialize();
  }

  @override
  void dispose() {
    _lastValue = null;
    _hasError = null;
    _subscription.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(StateBuilder<S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget?.stream ?? false) _initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) return widget.builder(context, _lastValue);
    return _hasError
        ? widget.onError(context, _lastValue.error)
        : widget.onData(context, _lastValue.data);
  }
}
