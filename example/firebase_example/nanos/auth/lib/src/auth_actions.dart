import 'package:nano/nano.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_models.dart';
import 'auth_state.dart';

class SignInParams {
  final AuthState store;
  final Credentials creds;
  SignInParams(this.store, this.creds);
}

class AuthActions {
  // We are not passing any mutations as AuthState is ProxyStream
  // that means we can't directly call mutations here
  // But we are supposed to call the methods that will modify the state of the
  // proxy stream is consuming
  // So basically this is the flow
  // Action --> Changes the state of Proxy Stream
  // --> Proxy Stream emits a new event
  // --> AuthState receives the event from Proxy Stream
  // --> AuthState.reducer is called from proxy mapper
  // --> reducer verifies if action was successfull

  static final signInAction = ProxyActionRef<SignInParams, FirebaseUser>(
    (payload) async {
      FirebaseAuth.instance.signOut();
      AuthResult result =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: payload.creds.email,
        password: payload.creds.password,
      );
      return result.user;
    },
    proxyStores: (payload) => [payload.store],
  );

  static final signOutAction = ProxyActionRef<AuthState, FirebaseUser>(
    (payload) async {
      await FirebaseAuth.instance.signOut();
      return;
    },
    proxyStores: (payload) => [payload],
  );
}
