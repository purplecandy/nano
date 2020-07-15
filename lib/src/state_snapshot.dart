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

  @override
  String toString() {
    return hasError ? error.toString() : data.toString();
  }
}
