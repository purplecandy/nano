/// Thrown when an action had a depdendency on other action (specified in `waitFor`) which didn't complete successfully.
/// Hence this an `IncompleteDepdendency` is thrown and your depdendent action is terminated.
class IncompleteDependency implements Exception {
  String message;
  IncompleteDependency(this.message);
  @override
  String toString() => "Exception: " + message;
}

class ActionTerminatedException implements Exception {
  ActionTerminatedException([var message]);
}
