class IncompleteDependency implements Exception {
  String message;
  IncompleteDependency(this.message);
  @override
  String toString() => "Exception: " + message;
}
