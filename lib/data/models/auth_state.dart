import 'package:meta/meta.dart';
import 'package:node_auth/data/data.dart';

@immutable
abstract class AuthenticationState {
  const AuthenticationState();

  UserAndToken get userAndToken;
}

class AuthenticatedState extends AuthenticationState {
  @override
  final UserAndToken userAndToken;

  const AuthenticatedState(this.userAndToken);
}

class UnauthenticatedState extends AuthenticationState {
  const UnauthenticatedState();

  @override
  UserAndToken get userAndToken => null;
}
