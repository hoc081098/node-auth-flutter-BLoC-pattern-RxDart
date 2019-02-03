import 'package:meta/meta.dart';

@immutable
abstract class AuthenticationState {}

class AuthenticatedState implements AuthenticationState {
  const AuthenticatedState();
}

class NotAuthenticatedState implements AuthenticationState {
  const NotAuthenticatedState();
}
