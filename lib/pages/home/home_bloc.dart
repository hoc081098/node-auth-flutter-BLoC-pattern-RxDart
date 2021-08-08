import 'dart:async';
import 'dart:io';

import 'package:disposebag/disposebag.dart';
import 'package:distinct_value_connectable_stream/distinct_value_connectable_stream.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:image_picker/image_picker.dart';
import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/domain/usecases/get_auth_state_stream_use_case.dart';
import 'package:node_auth/domain/usecases/logout_use_case.dart';
import 'package:node_auth/domain/usecases/upload_image_use_case.dart';
import 'package:node_auth/pages/home/home_state.dart';
import 'package:node_auth/utils/result.dart';
import 'package:node_auth/utils/type_defs.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

//ignore_for_file: close_sinks

/// BLoC that handles user profile and logout
class HomeBloc extends DisposeCallbackBaseBloc {
  /// Input functions
  final Function0<void> changeAvatar;
  final Function0<void> logout;

  /// Output stream
  final DistinctValueStream<AuthenticationState?> authState$;
  final Stream<HomeMessage> message$;

  HomeBloc._({
    required this.changeAvatar,
    required this.message$,
    required this.logout,
    required this.authState$,
    required Function0<void> dispose,
  }) : super(dispose);

  factory HomeBloc(
    final LogoutUseCase logout,
    final GetAuthStateStreamUseCase getAuthState,
    final UploadImageUseCase uploadImage,
  ) {
    final changeAvatarS = PublishSubject<void>();
    final logoutS = PublishSubject<void>();

    final Stream<AuthenticationState?> authenticationState$ = getAuthState();

    final logoutMessage$ = Rx.merge([
      logoutS.exhaustMap((_) => logout()).map(_resultToLogoutMessage),
      authenticationState$
          .where((state) => state!.userAndToken == null)
          .map((_) => const LogoutSuccessMessage()),
    ]);

    final updateAvatarMessage$ = changeAvatarS
        .exhaustMap(
          (value) => Rx.fromCallable(
            () => ImagePicker().pickImage(
              source: ImageSource.gallery,
              maxWidth: 720.0,
              maxHeight: 720.0,
            ),
          ),
        )
        .map((file) => file == null ? null : File(file.path))
        .whereNotNull()
        .distinct()
        .switchMap(uploadImage.call)
        .map(_resultToChangeAvatarMessage);

    final authState$ = authenticationState$.publishValueDistinct(null);

    final message$ = Rx.merge([logoutMessage$, updateAvatarMessage$]).publish();

    return HomeBloc._(
      changeAvatar: () => changeAvatarS.add(null),
      logout: () => logoutS.add(true),
      authState$: authState$,
      dispose: DisposeBag([
        authState$.connect(),
        message$.connect(),
        changeAvatarS,
        logoutS,
      ]).dispose,
      message$: message$,
    );
  }

  static LogoutMessage _resultToLogoutMessage(Result_Unit result) {
    return result.fold(
      (value) => const LogoutSuccessMessage(),
      (error, message) => LogoutErrorMessage(message, error),
    );
  }

  static UpdateAvatarMessage _resultToChangeAvatarMessage(Result_Unit result) {
    return result.fold(
      (value) => const UpdateAvatarSuccessMessage(),
      (error, message) => UpdateAvatarErrorMessage(message, error),
    );
  }
}
