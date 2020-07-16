import 'package:nano/nano.dart';

class LoggerMiddleWare extends Middleware {
  @override
  Future<Prop> run(state, action, props) async {
    print("LOGGER REPORT:");
    print("Action-> $action");
    print("State-> $state");
    print("Props-> $props");
    print("==END==");
    return Prop.success(props, allowNull: true);
  }
}
