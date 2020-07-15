import 'package:nano/nano.dart';

class LoggerMiddleWare extends MiddleWare {
  @override
  Future<Reply> run(state, action, props) async {
    print("LOGGER REPORT:");
    print("Action-> $action");
    print("State-> $state");
    print("Props-> $props");
    print("==END==");
    return Reply.success(props, allowNull: true);
  }
}
