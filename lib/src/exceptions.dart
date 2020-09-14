class IncompleteDependency implements Exception {
  String message;
  IncompleteDependency(this.message);
  @override
  String toString() => "Exception: " + message;
}

class ActionTerminatedException implements Exception {
  ActionTerminatedException([var message]);
}
