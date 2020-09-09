import 'package:demo/models/models.dart';
import 'package:nano/nano.dart';

abstract class AuthMutation {}

class SignInMutation extends AuthMutation {
  final User user;
  SignInMutation(this.user);
}

class SingOutMutation extends AuthMutation {}

class AuthStore extends Store<AuthModel, AuthMutation> {
  AuthStore() : super(AuthModel(AuthState.unauthorized, null));

  @override
  void reducer(AuthMutation mutation) {
    if (mutation is SignInMutation)
      updateState(AuthModel(AuthState.authorized, mutation.user));

    if (mutation is SingOutMutation) {
      updateState(AuthModel(AuthState.unauthorized, null));
    }
  }
}
