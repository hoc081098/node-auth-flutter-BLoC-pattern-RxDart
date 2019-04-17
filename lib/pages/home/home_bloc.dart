import 'dart:async';
import 'dart:io';

import 'package:distinct_value_connectable_observable/distinct_value_connectable_observable.dart';
import 'package:meta/meta.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/pages/home/home_state.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc {
  final void Function(File) changeAvatar;
  final void Function() logout;

  final ValueObservable<User> user$;
  final Stream<HomeMessage> message$;

  final void Function() dispose;

  HomeBloc._({
    @required this.changeAvatar,
    @required this.message$,
    @required this.logout,
    @required this.user$,
    @required this.dispose,
  });

  factory HomeBloc(UserRepository userRepository) {
    ///
    ///
    ///
    assert(userRepository != null);

    ///
    ///
    ///
    final changeAvatarController = PublishSubject<File>(); //ignore: close_sinks
    final logoutController = PublishSubject<void>(); //ignore: close_sinks

    ///
    ///
    ///
    final Observable<LogoutMessage> logoutMessage$ = Observable.merge([
      logoutController.exhaustMap((_) => userRepository.logout()).map((result) {
        if (result is Success) {
          return const LogoutSuccessMessage();
        }
        if (result is Failure) {
          return LogoutErrorMessage(result.message, result.error);
        }
      }),
      userRepository.userAndToken$
          .where((userAndToken) => userAndToken.user == null)
          .map((_) => const LogoutSuccessMessage()),
    ]);

    final Observable<UpdateAvatarMessage> updateAvatarMessage$ =
        changeAvatarController
            .where((file) => file != null)
            .distinct()
            .switchMap(userRepository.uploadImage)
            .map((result) {
      if (result is Success) {
        return const UpdateAvatarSuccessMessage();
      }
      if (result is Failure) {
        return UpdateAvatarErrorMessage(result.message, result.error);
      }
    });

    final user$ = publishValueSeededDistinct(
      userRepository.userAndToken$.map((userAndToken) => userAndToken.user),
      seedValue: userRepository.userAndToken$.value?.user,
    );

    final message$ = Observable.merge([
      logoutMessage$,
      updateAvatarMessage$,
    ]);

    ///
    ///
    ///
    final subscriptions = <StreamSubscription>[
      user$.connect(),
    ];

    return HomeBloc._(
      changeAvatar: changeAvatarController.add,
      logout: () => logoutController.add(true),
      user$: user$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait([
          changeAvatarController,
          logoutController,
        ].map((c) => c.close()));
      },
      message$: message$,
    );
  }
}
