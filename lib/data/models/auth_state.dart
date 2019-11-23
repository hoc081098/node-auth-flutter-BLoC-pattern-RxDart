import 'package:meta/meta.dart';
import 'package:node_auth/data/data.dart';

@immutable
abstract class AuthenticationState {
  const AuthenticationState();

  User get user {
    final self = this;
    if (self is AuthenticatedState) {
      return self.user;
    }
    if (self is UnauthenticatedState) {
      return null;
    }
    return null;
  }
}

class AuthenticatedState extends AuthenticationState {
  final User user;

  const AuthenticatedState(this.user);
}

class UnauthenticatedState extends AuthenticationState {
  const UnauthenticatedState();
}
