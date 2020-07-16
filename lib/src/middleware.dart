import 'package:nano/nano.dart';
import 'utils.dart';
import 'state_snapshot.dart';

abstract class Middleware {
  Future<Prop> run(StateSnapshot state, action, Prop props);
}
