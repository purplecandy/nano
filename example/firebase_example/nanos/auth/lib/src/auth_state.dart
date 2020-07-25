import 'package:firebase_auth/firebase_auth.dart';
import 'package:nano/nano.dart';

abstract class AuthMutations {}

class SignInMutation extends AuthMutations {
  final FirebaseUser user;
  SignInMutation(this.user);
}

class SignOutMutation extends AuthMutations {}

class AuthState extends Store<FirebaseUser, AuthMutations>
    with ProxyStream<FirebaseUser> {
  @override
  bool get setInitialState => false;

  @override
  void mapper({FirebaseUser event, bool isError = false, Object error}) {
    if (event != null)
      proxyReducer(this, SignInMutation(event));
    else
      proxyReducer(this, SignOutMutation());
  }

  @override
  void reducer(AuthMutations mutation) {
    if (mutation is SignInMutation) updateState(mutation.user);
    if (mutation is SignOutMutation) updateStateWithError("Unauthorised");
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }
}
