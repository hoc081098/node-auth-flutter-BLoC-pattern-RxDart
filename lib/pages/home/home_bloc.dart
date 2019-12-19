import 'dart:async';
import 'dart:io';

import 'package:disposebag/disposebag.dart';
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:meta/meta.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/pages/home/home_state.dart';
import 'package:rxdart/rxdart.dart';

//ignore_for_file: close_sinks

class HomeBloc {
  /// Input functions
  final void Function(File) changeAvatar;
  final void Function() logout;

  /// Output stream
  final ValueStream<User> user$;
  final Stream<HomeMessage> message$;

  /// Clean up
  final void Function() dispose;

  HomeBloc._({
    @required this.changeAvatar,
    @required this.message$,
    @required this.logout,
    @required this.user$,
    @required this.dispose,
  });

  factory HomeBloc(UserRepository userRepository) {
    assert(userRepository != null);

    final changeAvatarS = PublishSubject<File>();
    final logoutS = PublishSubject<void>();

    final authenticationState$ = userRepository.authenticationState$;

    final logoutMessage$ = Rx.merge([
      logoutS
          .exhaustMap((_) => userRepository.logout())
          .map(_resultToLogoutMessage),
      authenticationState$
          .where((state) => state.userAndToken == null)
          .map((_) => const LogoutSuccessMessage()),
    ]);

    final updateAvatarMessage$ = changeAvatarS
        .where((file) => file != null)
        .distinct()
        .switchMap(userRepository.uploadImage)
        .map(_resultToChangeAvatarMessage);

    final user$ = authenticationState$
        .map((state) => state.userAndToken?.user)
        .publishValueSeededDistinct(
            seedValue: authenticationState$.value?.userAndToken?.user);

    final message$ = Rx.merge([logoutMessage$, updateAvatarMessage$]).publish();

    return HomeBloc._(
      changeAvatar: changeAvatarS.add,
      logout: () => logoutS.add(true),
      user$: user$,
      dispose: DisposeBag([
        user$.connect(),
        message$.connect(),
        changeAvatarS,
        logoutS,
      ]).dispose,
      message$: message$,
    );
  }

  static LogoutMessage _resultToLogoutMessage(result) {
    if (result is Success) {
      return const LogoutSuccessMessage();
    }
    if (result is Failure) {
      return LogoutErrorMessage(result.message, result.error);
    }
    return null;
  }

  static UpdateAvatarMessage _resultToChangeAvatarMessage(result) {
    if (result is Success) {
      return const UpdateAvatarSuccessMessage();
    }
    if (result is Failure) {
      return UpdateAvatarErrorMessage(result.message, result.error);
    }
    return null;
  }
}
