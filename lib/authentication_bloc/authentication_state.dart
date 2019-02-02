import 'package:meta/meta.dart';
import 'package:node_auth/data/models/user_and_token.dart';

@immutable
abstract class AuthenticationState {}

class AuthenticatedState implements AuthenticationState {
  final UserAndToken userAndToken;

  const AuthenticatedState(this.userAndToken);
}

class NotAuthenticatedState implements AuthenticationState {
  const NotAuthenticatedState();
}
