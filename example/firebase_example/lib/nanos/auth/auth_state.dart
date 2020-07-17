import 'package:firebase_auth/firebase_auth.dart';
import 'auth_models.dart';
import 'package:nano/nano.dart';

enum AuthActions {
  signIn,
  signOut,
}

class AuthState extends StateManager<FirebaseUser, AuthActions>
    with ProxyStream<FirebaseUser> {
  AuthState() : super(null);
  @override
  void mapper({FirebaseUser event, bool isError = false, Object error}) {
    if (event != null)
      updateState(event);
    else
      updateStateWithError("Unauthorised");
  }

  @override
  Future<void> reducer(AuthActions action, Prop props) async {
    if (action == AuthActions.signIn) {
      Credentials credential = props.data;
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: credential.email, password: credential.password);
    }
    if (action == AuthActions.signOut) {
      FirebaseAuth.instance.signOut();
    }
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }
}
