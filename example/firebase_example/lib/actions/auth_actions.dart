import 'package:nano/nano.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_models.dart';
import '../refs.dart';
import '../stores/auth_store.dart';
import '../stores/auth_store.dart';
import '../stores/stores.dart';
import '../models/models.dart';

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

  static final signInAction = ActionRef<Credentials, FirebaseUser>(
    body: (payload) async {
      FirebaseAuth.instance.signOut();
      AuthResult result =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: payload.email,
        password: payload.password,
      );
      return result.user;
    },
    store: (_) => authRef.store,
    mutation: (user, _) => SignInMutation(user),
  );

  static final signOutAction = ActionRef<Null, FirebaseUser>(
    body: (_) async {
      await FirebaseAuth.instance.signOut();
      return;
    },
    store: (_) => authRef.store,
    mutation: (_, __) => SignOutMutation(),
  );
}
