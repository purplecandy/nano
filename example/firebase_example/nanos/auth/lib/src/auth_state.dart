import 'package:firebase_auth/firebase_auth.dart';
import 'package:nano/nano.dart';

abstract class AuthMutations {}

class SignInMutation extends AuthMutations {
  final FirebaseUser user;
  SignInMutation(this.user);
}

class SignOutMutation extends AuthMutations {}

class AuthState extends StateManager<FirebaseUser, AuthMutations>
    with ProxyStream<FirebaseUser> {
  @override
  bool get setInitialState => false;

  @override
  void mapper({FirebaseUser event, bool isError = false, Object error}) {
    if (event != null)
      reducer(SignInMutation(event), null);
    else
      reducer(SignOutMutation(), null);
  }

  @override
  Future<void> reducer(AuthMutations action, Prop props) async {
    if (action is SignInMutation) updateState(action.user);
    if (action is SignOutMutation) updateStateWithError("Unauthorised");
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }
}
