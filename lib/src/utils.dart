/// Status for [AsyncResponse]
enum Status {
  success,

  /// known exception e.g SocketIo
  failed,

  /// exception
  unkown,

  /// custom error
  error,

  /// in between
  loading,

  /// not ready
  idle,
}

/// An improved implementation of AsyncResponse
class Reply<T> {
  final Status status;
  final T data;
  final dynamic error;
  Reply({this.status, this.data, this.error, allowNull = true})
      : assert(
            (allowNull
                ? true
                : (data != null && error == null) ||
                    (data == null && error != null)),
            "Both data and error can't be true at the same time");

  bool get isUnknown => status == Status.unkown;
  bool get isSuccess => status == Status.success;

  factory Reply.success(T data, {bool allowNull = false}) =>
      Reply(status: Status.success, data: data, allowNull: allowNull);
  factory Reply.error(Status status, [dynamic error = ""]) =>
      Reply(status: status, error: error);
}
