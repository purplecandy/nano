import 'package:demo/exceptions.dart';
import 'package:demo/models/models.dart';
import 'package:demo/refs.dart';
import 'package:demo/stores/auth_store.dart';
import 'package:nano/nano.dart';

class AuthActions {
  static final signIn = ActionRef<String, User>(
    body: (name) async {
      final user = dbRef.store.find(name);
      if (user == null)
        throw InvalidCredentials();
      else
        return User.fromJson(user);
    },
    store: (_) => authRef.store,
    mutation: (response, payload) => SignInMutation(response),
  );
}
