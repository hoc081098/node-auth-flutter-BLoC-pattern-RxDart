import 'package:built_value/built_value.dart';
import 'package:meta/meta.dart';
import 'package:node_auth/domain/models/user_and_token.dart';

part 'auth_state.g.dart';

@immutable
abstract class AuthenticationState {
  const AuthenticationState();

  UserAndToken? get userAndToken;
}

abstract class AuthenticatedState
    implements
        Built<AuthenticatedState, AuthenticatedStateBuilder>,
        AuthenticationState {
  @override
  UserAndToken get userAndToken;

  AuthenticatedState._();

  factory AuthenticatedState(
          [void Function(AuthenticatedStateBuilder) updates]) =
      _$AuthenticatedState;
}

abstract class UnauthenticatedState
    implements
        Built<UnauthenticatedState, UnauthenticatedStateBuilder>,
        AuthenticationState {
  @override
  UserAndToken? get userAndToken => null;

  UnauthenticatedState._();

  factory UnauthenticatedState(
          [void Function(UnauthenticatedStateBuilder) updates]) =
      _$UnauthenticatedState;
}
