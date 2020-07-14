import 'utils.dart';
import 'state_snapshot.dart';

abstract class MiddleWare {
  Future<Reply> run(StateSnapshot state, action, props);
}
