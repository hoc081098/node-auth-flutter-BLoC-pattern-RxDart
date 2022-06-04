import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:node_auth/domain/usecases/change_password_use_case.dart';
import 'package:node_auth/pages/home/change_password/change_password.dart';
import 'package:node_auth/utils/result.dart';
import 'package:node_auth/utils/streams.dart';
import 'package:node_auth/utils/type_defs.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:tuple/tuple.dart';

bool _isValidPassword(String password) {
  return password.length >= 6;
}

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

    final both$ = Rx.combineLatest2(
      passwordS.stream.startWith(''),
      newPasswordS.stream.startWith(''),
      (String password, String newPassword) => Tuple2(password, newPassword),
    ).share();

    final isValidSubmit$ = both$.map((both) {
      final password = both.item1;
      final newPassword = both.item2;
      return _isValidPassword(newPassword) &&
          _isValidPassword(password) &&
          password != newPassword;
    }).shareValueSeeded(false);

    final changePasswordState$ = submitChangePasswordS.stream
        .withLatestFrom(isValidSubmit$, (_, bool isValid) => isValid)
        .debug()
        .where((isValid) => isValid)
        .withLatestFrom(both$, (_, Tuple2<String, String> both) => both)
        .exhaustMap((both) => _performChangePassword(changePassword, both))
        .publishState(ChangePasswordState((b) => b..isLoading = false));

    final passwordError$ = both$
        .map((tuple) {
          final password = tuple.item1;
          final newPassword = tuple.item2;

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
        .map((tuple) {
          final password = tuple.item1;
          final newPassword = tuple.item2;

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

    final subscriptions = <String, Stream>{
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
    Tuple2<String, String> both,
  ) {
    debugPrint('[DEBUG] change password both=$both');

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
          ..message = 'Error when change password: ${appError.message}'),
      );
    }

    return changePassword(password: both.item1, newPassword: both.item2)
        .map(resultToState)
        .startWith(
          ChangePasswordState((b) => b
            ..isLoading = true
            ..error = null
            ..message = null),
        );
  }
}
