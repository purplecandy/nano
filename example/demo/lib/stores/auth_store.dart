import 'package:demo/models/models.dart';
import 'package:nano/nano.dart';

abstract class AuthMutation {}

class SignInMutation extends AuthMutation {
  final User user;
  SignInMutation(this.user);
}

class SignOutMutation extends AuthMutation {}

class AuthStore extends Store<AuthModel, AuthMutation> {
  @override
  bool get setInitialState => false;

  
  @override
  void reducer(AuthMutation mutation) {
    if (mutation is SignInMutation)
      updateState(AuthModel(AuthState.authorized, mutation.user));

    if (mutation is SignOutMutation) {
      updateState(AuthModel(AuthState.unauthorized, null));
    }
  }
}
