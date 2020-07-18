import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'state_snapshot.dart';

typedef bool BuilderCondition<T>(StateSnapshot<T> state);
typedef Widget SnapBuilder<T>(BuildContext context, StateSnapshot<T> event);
typedef Widget DataBuilderFn<T>(BuildContext context, T data);
typedef Widget ErrorBuilderFn(BuildContext context, Object error);

class StateBuilder<T> extends StatefulWidget {
  final StateSnapshot<T> initialState;
  final Stream<StateSnapshot<T>> stream;
  final BuilderCondition<T> rebuildOnly;
  final SnapBuilder<T> builder;
  final DataBuilderFn<T> onData;
  final ErrorBuilderFn onError;
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
  _StateBuilderState createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T> extends State<StateBuilder<T>> {
  Stream<StateSnapshot<T>> get stream => widget.stream;
  StreamSubscription _subscription;
  StateSnapshot<T> _lastValue;
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
  void didUpdateWidget(StateBuilder<T> oldWidget) {
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
