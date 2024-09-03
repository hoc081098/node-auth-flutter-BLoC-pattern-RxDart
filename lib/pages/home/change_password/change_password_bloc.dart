import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/usecases/change_password_use_case.dart';
import 'package:node_auth/pages/home/change_password/change_password.dart';
import 'package:node_auth/utils/streams.dart';
import 'package:node_auth/utils/type_defs.dart';

bool _isValidPassword(String password) => password.length >= 6;

typedef _FormInfo = ({String password, String newPassword});

// ignore_for_file: close_sinks

/// BLoC that handles changing password
class ChangePasswordBloc extends DisposeCallbackBaseBloc {
  /// Input functions
  final Function0<void> changePassword;
  final Function1<String, void> passwordChanged;
  final Function1<String, void> newPasswordChanged;

  /// Output stream
  final StateStream<ChangePasswordState> changePasswordState$;
  final Stream<String?> passwordError$;
  final Stream<String?> newPasswordError$;

  ChangePasswordBloc._({
    required this.changePassword,
    required this.changePasswordState$,
    required Function0<void> dispose,
    required this.passwordChanged,
    required this.newPasswordChanged,
    required this.passwordError$,
    required this.newPasswordError$,
  }) : super(dispose);

  factory ChangePasswordBloc(final ChangePasswordUseCase changePassword) {
    /// Controllers
    final passwordS = PublishSubject<String>();
    final newPasswordS = PublishSubject<String>();
    final submitChangePasswordS = PublishSubject<void>();
    final controllers = [newPasswordS, passwordS, submitChangePasswordS];

    ///
    /// Streams
    ///

    final Stream<_FormInfo> both$ = Rx.combineLatest2(
      passwordS.stream.startWith(''),
      newPasswordS.stream.startWith(''),
      (String password, String newPassword) =>
          (password: password, newPassword: newPassword),
    ).share();

    final isValidSubmit$ = both$
        .map(
          (formInfo) =>
              _isValidPassword(formInfo.newPassword) &&
              _isValidPassword(formInfo.password) &&
              formInfo.password != formInfo.newPassword,
        )
        .shareValueSeeded(false);

    final changePasswordState$ = submitChangePasswordS.stream
        .withLatestFrom(isValidSubmit$, (_, bool isValid) => isValid)
        .debug()
        .where((isValid) => isValid)
        .withLatestFrom(both$, (_, formInfo) => formInfo)
        .exhaustMap((both) => _performChangePassword(changePassword, both))
        .publishState(ChangePasswordState((b) => b..isLoading = false));

    final passwordError$ = both$
        .map((formInfo) {
          final password = formInfo.password;
          final newPassword = formInfo.newPassword;

          if (!_isValidPassword(password)) {
            return 'Password must be at least 6 characters';
          }

          if (_isValidPassword(newPassword) && password == newPassword) {
            return 'New password is same old password!';
          }

          return null;
        })
        .distinct()
        .share();

    final newPasswordError$ = both$
        .map((formInfo) {
          final password = formInfo.password;
          final newPassword = formInfo.newPassword;

          if (!_isValidPassword(newPassword)) {
            return 'New password must be at least 6 characters';
          }

          if (_isValidPassword(password) && password == newPassword) {
            return 'New password is same old password!';
          }

          return null;
        })
        .distinct()
        .share();

    final subscriptions = <String, Stream<dynamic>>{
      'newPasswordError': newPasswordError$,
      'passwordError': passwordError$,
      'isValidSubmit': isValidSubmit$,
      'both': both$,
      'changePasswordState': changePasswordState$,
    }.debug();

    return ChangePasswordBloc._(
      dispose: DisposeBag([
        ...subscriptions,
        ...controllers,
        changePasswordState$.connect(),
      ]).dispose,
      changePassword: () => submitChangePasswordS.add(null),
      changePasswordState$: changePasswordState$,
      passwordChanged: passwordS.add,
      newPasswordChanged: newPasswordS.add,
      passwordError$: passwordError$,
      newPasswordError$: newPasswordError$,
    );
  }

  static Stream<ChangePasswordState> _performChangePassword(
    ChangePasswordUseCase changePassword,
    _FormInfo formInfo,
  ) {
    debugPrint('[DEBUG] change password both=$formInfo');

    ChangePasswordState resultToState(UnitResult result) {
      debugPrint('[DEBUG] change password result=$result');

      return result.fold(
        ifRight: (_) => ChangePasswordState((b) => b
          ..isLoading = false
          ..error = null
          ..message = 'Change password successfully!'),
        ifLeft: (appError) => ChangePasswordState((b) => b
          ..isLoading = false
          ..error = appError.error
          ..message = appError.isCancellation
              ? null
              : 'Error when change password: ${appError.message}'),
      );
    }

    return changePassword(
            password: formInfo.password, newPassword: formInfo.newPassword)
        .map(resultToState)
        .startWith(
          ChangePasswordState((b) => b
            ..isLoading = true
            ..error = null
            ..message = null),
        );
  }
}
