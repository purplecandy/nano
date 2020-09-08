import 'package:firebase_auth/firebase_auth.dart';
import 'package:nano/nano.dart';

abstract class AuthMutations {}

class SignInMutation extends AuthMutations {
  final FirebaseUser user;
  SignInMutation(this.user);
}

class SignOutMutation extends AuthMutations {}

class AuthStore extends Store<FirebaseUser, AuthMutations> {
  @override
  bool get setInitialState => false;

  @override
  void reducer(AuthMutations mutation) {
    if (mutation is SignInMutation) updateState(mutation.user);
    if (mutation is SignOutMutation) updateStateWithError("Unauthorised");
  }
}
