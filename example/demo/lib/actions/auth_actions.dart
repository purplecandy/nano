import 'package:demo/exceptions.dart';
import 'package:demo/models/models.dart';
import 'package:demo/refs.dart';
import 'package:demo/stores/auth_store.dart';
import 'package:nano/nano.dart';

// class AuthActions {
//   static final signIn = ActionRef<String, User>(
//     body: (name) async {
//       ,
//     store: (_) => authRef.store,
//     mutation: (response, payload) => SignInMutation(response),
//   );
// }

Stream<Mutation> signIn(name) async* {
  final user = dbRef.store.find(name);
  if (user != null) {
    var userModel = User.fromJson(user);
    yield Mutation(authRef.store, SignInMutation(userModel));
  } else
    throw InvalidCredentials();
}
