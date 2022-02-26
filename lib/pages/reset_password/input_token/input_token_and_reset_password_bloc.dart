import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:node_auth/domain/usecases/reset_password_use_case.dart';
import 'package:node_auth/utils/result.dart';
import 'package:node_auth/utils/type_defs.dart';
import 'package:node_auth/utils/validators.dart';
import 'package:rxdart_ext/rxdart_ext.dart';
import 'package:tuple/tuple.dart';

abstract class InputTokenAndResetPasswordMessage {}

class InvalidInformation implements InputTokenAndResetPasswordMessage {
  const InvalidInformation();
}

class ResetPasswordSuccess implements InputTokenAndResetPasswordMessage {
  final String email;

  const ResetPasswordSuccess(this.email);
}

class ResetPasswordFailure implements InputTokenAndResetPasswordMessage {
  final String message;
  final Object error;

  const ResetPasswordFailure(this.error, this.message);
}

//ignore_for_file: close_sinks

class InputTokenAndResetPasswordBloc extends DisposeCallbackBaseBloc {
  final Function1<String, void> emailChanged;
  final Function1<String, void> passwordChanged;
  final Function1<String, void> tokenChanged;
  final Function0<void> submit;

  final Stream<String?> emailError$;
  final Stream<String?> passwordError$;
  final Stream<String?> tokenError$;
  final Stream<bool> isLoading$;
  final Stream<InputTokenAndResetPasswordMessage> message$;

  InputTokenAndResetPasswordBloc._({
    required this.emailChanged,
    required this.passwordChanged,
    required this.tokenChanged,
    required this.emailError$,
    required this.passwordError$,
    required this.tokenError$,
    required Function0<void> dispose,
    required this.submit,
    required this.isLoading$,
    required this.message$,
  }) : super(dispose);

  factory InputTokenAndResetPasswordBloc(
      final ResetPasswordUseCase resetPassword) {
    final emailSubject = BehaviorSubject<String>.seeded('');
    final tokenSubject = BehaviorSubject<String>.seeded('');
    final passwordSubject = BehaviorSubject<String>.seeded('');
    final submitSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);
    final subjects = [
      emailSubject,
      tokenSubject,
      passwordSubject,
      submitSubject,
      isLoadingSubject,
    ];

    ///
    /// Stream
    ///
    final emailError$ = emailSubject.map((email) {
      if (Validator.isValidEmail(email)) return null;
      return 'Invalid email address';
    }).share();

    final passwordError$ = passwordSubject.map((password) {
      if (Validator.isValidPassword(password)) return null;
      return 'Password must be at least 6 characters';
    }).share();

    final tokenError$ = tokenSubject.map((token) {
      if (token.isNotEmpty) return null;
      return 'Token must be not empty';
    }).share();

    final allField$ = submitSubject
        .map((_) => Tuple3(
            emailSubject.value, tokenSubject.value, passwordSubject.value))
        .share();

    bool allFieldsAreValid(Tuple3<String, String, String> tuple3) {
      return Validator.isValidEmail(tuple3.item1) &&
          tuple3.item2.isNotEmpty &&
          Validator.isValidPassword(tuple3.item3);
    }

    final message$ = Rx.merge([
      allField$
          .where((tuple3) => !allFieldsAreValid(tuple3))
          .map((_) => const InvalidInformation()),
      allField$
          .where(allFieldsAreValid)
          .exhaustMap((tuple3) => _sendResetPasswordRequest(
                resetPassword,
                tuple3,
                isLoadingSubject,
              )),
    ]).share();

    return InputTokenAndResetPasswordBloc._(
      dispose: DisposeBag(subjects).dispose,
      emailChanged: trim.pipe(emailSubject.add),
      tokenChanged: tokenSubject.add,
      passwordChanged: passwordSubject.add,
      submit: () => submitSubject.add(null),
      passwordError$: passwordError$,
      emailError$: emailError$,
      isLoading$: isLoadingSubject,
      tokenError$: tokenError$,
      message$: message$,
    );
  }

  static Stream<InputTokenAndResetPasswordMessage> _sendResetPasswordRequest(
    ResetPasswordUseCase resetPassword,
    Tuple3<String, String, String> tuple3,
    Sink<bool> isLoadingSink,
  ) {
    final email = tuple3.item1;
    return resetPassword(
            email: email, token: tuple3.item2, newPassword: tuple3.item3)
        .doOn(
          listen: () => isLoadingSink.add(true),
          cancel: () => isLoadingSink.add(false),
        )
        .map(
          (result) => result.fold(
            (_) => ResetPasswordSuccess(email),
            (error, message) => ResetPasswordFailure(error, message),
          ),
        );
  }
}
