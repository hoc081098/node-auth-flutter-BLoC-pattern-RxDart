import 'dart:async';
import 'dart:io';

import 'package:disposebag/disposebag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:image_picker/image_picker.dart';
import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/models/auth_state.dart';
import 'package:node_auth/domain/usecases/get_auth_state_stream_use_case.dart';
import 'package:node_auth/domain/usecases/logout_use_case.dart';
import 'package:node_auth/domain/usecases/upload_image_use_case.dart';
import 'package:node_auth/pages/home/home_state.dart';
import 'package:node_auth/utils/streams.dart';
import 'package:node_auth/utils/type_defs.dart';

//ignore_for_file: close_sinks

/// BLoC that handles user profile and logout
class HomeBloc extends DisposeCallbackBaseBloc {
  /// Input functions
  final Function0<void> changeAvatar;
  final Function0<void> logout;

  /// Output stream
  final StateStream<Result<AuthenticationState>?> authState$;
  final Stream<HomeMessage> message$;
  final StateStream<bool> isUploading$;

  HomeBloc._({
    required this.changeAvatar,
    required this.message$,
    required this.logout,
    required this.authState$,
    required this.isUploading$,
    required Function0<void> dispose,
  }) : super(dispose);

  factory HomeBloc(
    final LogoutUseCase logout,
    final GetAuthStateStreamUseCase getAuthState,
    final UploadImageUseCase uploadImage,
  ) {
    final changeAvatarS = PublishSubject<void>();
    final logoutS = PublishSubject<void>();
    final isUploading$ = StateSubject(false);

    final authenticationState$ = getAuthState();

    final logoutMessage$ = Rx.merge([
      logoutS.exhaustMap((_) => logout()).map(_resultToLogoutMessage),
      authenticationState$
          .where((result) => result.orNull()?.userAndToken == null)
          .mapTo(const LogoutSuccessMessage()),
    ]);

    final imagePicker = ImagePicker();
    final updateAvatarMessage$ = changeAvatarS
        .debug(identifier: 'changeAvatar [1]', log: debugPrint)
        .switchMap(
          (_) => Rx.fromCallable(
            () => imagePicker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 720.0,
              maxHeight: 720.0,
            ),
          ).debug(identifier: 'pickImage', log: debugPrint),
        )
        .debug(identifier: 'changeAvatar [2]', log: debugPrint)
        .map((file) => file == null ? null : File(file.path))
        .whereNotNull()
        .distinct()
        .switchMap(
          (file) => uploadImage(file).doOn(
              listen: () => isUploading$.value = true,
              cancel: () => isUploading$.value = false),
        )
        .debug(identifier: 'changeAvatar [3]', log: debugPrint)
        .map(_resultToChangeAvatarMessage);

    final authState$ = authenticationState$.castAsNullable().publishState(null);

    final message$ = Rx.merge([logoutMessage$, updateAvatarMessage$])
        .whereNotNull()
        .publish();

    return HomeBloc._(
      changeAvatar: () => changeAvatarS.add(null),
      logout: () => logoutS.add(null),
      authState$: authState$,
      isUploading$: isUploading$,
      dispose: DisposeBag([
        authState$.connect(),
        message$.connect(),
        changeAvatarS,
        logoutS,
        isUploading$,
      ]).dispose,
      message$: message$,
    );
  }

  static LogoutMessage? _resultToLogoutMessage(UnitResult result) {
    return result.fold(
      ifRight: (_) => const LogoutSuccessMessage(),
      ifLeft: (appError) => appError.isCancellation
          ? null
          : LogoutErrorMessage(appError.message!, appError.error!),
    );
  }

  static UpdateAvatarMessage? _resultToChangeAvatarMessage(UnitResult result) {
    return result.fold(
      ifRight: (_) => const UpdateAvatarSuccessMessage(),
      ifLeft: (appError) => appError.isCancellation
          ? null
          : UpdateAvatarErrorMessage(appError.message!, appError.error!),
    );
  }
}
