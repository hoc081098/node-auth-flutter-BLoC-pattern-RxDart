import 'dart:async';
import 'dart:io';

import 'package:disposebag/disposebag.dart';
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:meta/meta.dart';
import 'package:node_auth/domain/models/user.dart';
import 'package:node_auth/domain/usecases/get_auth_state_use_case.dart';
import 'package:node_auth/domain/usecases/logout_use_case.dart';
import 'package:node_auth/domain/usecases/upload_image_use_case.dart';
import 'package:node_auth/my_base_bloc.dart';
import 'package:node_auth/pages/home/home_state.dart';
import 'package:node_auth/utils/result.dart';
import 'package:node_auth/utils/type_defs.dart';
import 'package:rxdart/rxdart.dart';

//ignore_for_file: close_sinks

/// BLoC that handles user profile and logout
class HomeBloc extends MyBaseBloc {
  /// Input functions
  final Function1<File, void> changeAvatar;
  final Function0<void> logout;

  /// Output stream
  final ValueStream<User> user$;
  final Stream<HomeMessage> message$;

  HomeBloc._({
    @required this.changeAvatar,
    @required this.message$,
    @required this.logout,
    @required this.user$,
    @required Function0<void> dispose,
  }) : super(dispose);

  factory HomeBloc(
    final LogoutUseCase logout,
    final GetAuthStateUseCase getAuthState,
    final UploadImageUseCase uploadImage,
  ) {
    assert(logout != null);
    assert(getAuthState != null);

    final changeAvatarS = PublishSubject<File>();
    final logoutS = PublishSubject<void>();

    final authenticationState$ = getAuthState();

    final logoutMessage$ = Rx.merge([
      logoutS.exhaustMap((_) => logout.call()).map(_resultToLogoutMessage),
      authenticationState$
          .where((state) => state.userAndToken == null)
          .map((_) => const LogoutSuccessMessage()),
    ]);

    final updateAvatarMessage$ = changeAvatarS
        .where((file) => file != null)
        .distinct()
        .switchMap(uploadImage)
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
