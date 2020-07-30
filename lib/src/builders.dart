import 'package:flutter/material.dart';
import 'dart:async';
import 'state_snapshot.dart';

typedef bool BuilderCondition<T>(StateSnapshot<T> state);
typedef Widget SnapBuilder<T>(
    BuildContext context, StateSnapshot<T> event, bool initialized);
typedef Widget DataBuilderFn<T>(BuildContext context, T data);
typedef Widget ErrorBuilderFn(BuildContext context, Object error);
typedef Widget WaitingBuilderFn(BuildContext context);

class StateBuilder<T> extends StatefulWidget {
  final StateSnapshot<T> initialState;
  final Stream<StateSnapshot<T>> stream;
  final BuilderCondition<T> rebuildOnly;
  final SnapBuilder<T> builder;
  final DataBuilderFn<T> onData;
  final ErrorBuilderFn onError;
  final WaitingBuilderFn waiting;
  const StateBuilder(
      {Key key,
      @required this.initialState,
      @required this.stream,
      this.rebuildOnly,
      this.onData,
      this.onError,
      this.waiting,
      this.builder})
      : assert(!(builder != null && (onData != null || onError != null))),
        assert(initialState != null),
        assert(stream != null),
        super(key: key);
  @override
  _StateBuilderState createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T> extends State<StateBuilder<T>> {
  Stream<StateSnapshot<T>> get stream => widget.stream;
  StreamSubscription _subscription;
  StateSnapshot<T> _lastValue;
  bool _hasError = false;
  bool _unInitialized = false;
  void _initialize() {
    if (widget.initialState.waiting) _unInitialized = true;
    _hasError = widget.initialState.hasError;
    _lastValue = widget.initialState;
    _subscription = stream.listen((event) {
      if (widget.rebuildOnly != null) {
        if (widget.rebuildOnly.call(event)) {
          _lastValue = event;
        }
      } else {
        _lastValue = event;
      }
      _hasError = false;
      _unInitialized = false;
      setState(() {});
    }, onError: (snap) {
      setState(() {
        _unInitialized = false;
        _hasError = true;
        _lastValue = snap;
      });
    }, onDone: () {
      if (mounted) {
        print("Your store has been disposed but you have an active listener");
        print(
            "Acoording to the Flutter Widget tree, the listerners should be disposed");
      }
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
    if (widget.builder != null)
      return widget.builder(context, _lastValue, !_unInitialized);
    if (_unInitialized) return widget.waiting(context);
    return _hasError
        ? widget.onError(context, _lastValue.error)
        : widget.onData(context, _lastValue.data);
  }
}
