import 'package:meta/meta.dart';
import 'package:node_auth/data/data.dart';

@immutable
abstract class AuthenticationState {
  const AuthenticationState();

  UserAndToken get userAndToken {
    final self = this;
    if (self is AuthenticatedState) {
      return self.userAndToken;
    }
    return null;
  }
}

class AuthenticatedState extends AuthenticationState {
  final UserAndToken userAndToken;

  const AuthenticatedState(this.userAndToken);
}

class UnauthenticatedState extends AuthenticationState {
  const UnauthenticatedState();
}
