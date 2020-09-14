import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

/// Current state of the store.
@immutable
class StateSnapshot<T> {
  final T data;
  final Object error;

  const StateSnapshot(
    this.data,
    this.error,
  ) : assert(!(data != null && error != null),
            "Both data and error cant be set at the same time");
  bool get hasData => data != null;
  bool get hasError => error != null;
  bool get waiting => data == null && error == null;
  @override
  String toString() {
    return hasError ? error.toString() : data.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StateSnapshot<T> &&
        other.data == data &&
        other.error == error;
  }

  @override
  int get hashCode => hashValues(data, error);
}
