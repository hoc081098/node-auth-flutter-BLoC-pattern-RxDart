import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:meta/meta.dart';
import 'package:node_auth/authentication_bloc/authentication.dart';
import 'package:node_auth/data/data.dart';

class AuthenticationBloc {
  ///
  /// Streams
  ///
  final Stream<AuthenticationState> authenticationState$;

  ///
  /// Clean up
  ///
  final void Function() dispose;

  AuthenticationBloc._({
    @required this.authenticationState$,
    @required this.dispose,
  });

  factory AuthenticationBloc(UserRepository userRepository) {
    final authenticationState$ = DistinctValueConnectableObservable(
      userRepository.userAndToken$.map((userAndToken) {
        if (userAndToken.user == null || userAndToken.token == null) {
          return const NotAuthenticatedState();
        } else {
          return const AuthenticatedState();
        }
      }),
    );
    final subscription = authenticationState$.connect();

    return AuthenticationBloc._(
      authenticationState$: authenticationState$,
      dispose: () async {
        await subscription.cancel();
      },
    );
  }
}
