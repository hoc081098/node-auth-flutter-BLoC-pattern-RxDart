import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:meta/meta.dart';
import 'package:node_auth/authentication_bloc/authentication_state.dart';
import 'package:node_auth/data/user_repository.dart';
import 'package:rxdart/rxdart.dart';

class AuthenticationBloc {
  ///
  /// Input functions
  ///
  final void Function() logout;

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
    @required this.logout,
  });

  factory AuthenticationBloc(UserRepository userRepository) {
    final logoutController = PublishSubject<void>();

    final authState$ = userRepository.userAndToken$.map((userAndToken) {
      if (userAndToken.user == null || userAndToken.token == null) {
        return const NotAuthenticatedState();
      } else {
        return AuthenticatedState(userAndToken);
      }
    });
    final authenticationState$ = DistinctValueConnectableObservable(authState$);

    logoutController.exhaustMap((_) => userRepository.logout()).listen(null);

    final compositeSubscription = CompositeSubscription()
      ..add(authenticationState$.connect());

    return AuthenticationBloc._(
      authenticationState$: authenticationState$,
      dispose: () async {
        compositeSubscription.dispose();
        logoutController.close();
      },
      logout: () => logoutController.add(null),
    );
  }
}
