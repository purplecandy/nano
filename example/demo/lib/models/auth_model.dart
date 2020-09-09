import 'package:demo/models/models.dart';

enum AuthState {
  unauthorized,
  authorized,
}

class AuthModel {
  final AuthState state;
  final User user;
  AuthModel(this.state, this.user);
}
