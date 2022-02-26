// ignore_for_file: close_sinks

import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:node_auth/domain/usecases/send_reset_password_email_use_case.dart';
import 'package:node_auth/pages/reset_password/send_email/send_email.dart';
import 'package:node_auth/utils/result.dart';
import 'package:node_auth/utils/type_defs.dart';
import 'package:node_auth/utils/validators.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class SendEmailBloc extends DisposeCallbackBaseBloc {
  ///
  final Function0<void> submit;
  final Function1<String, void> emailChanged;

  ///
  final Stream<String?> emailError$;
  final Stream<SendEmailMessage> message$;
  final Stream<bool> isLoading$;

  SendEmailBloc._({
    required this.submit,
    required this.emailChanged,
    required this.emailError$,
    required this.message$,
    required this.isLoading$,
    required Function0<void> dispose,
  }) : super(dispose);

  factory SendEmailBloc(
      final SendResetPasswordEmailUseCase sendResetPasswordEmail) {
    final emailS = PublishSubject<String>();
    final submitS = PublishSubject<void>();
    final isLoadingS = BehaviorSubject<bool>.seeded(false);

    final emailError$ = emailS.map((email) {
      if (Validator.isValidEmail(email)) return null;
      return 'Invalid email address';
    }).share();

    final submittedEmail$ =
        submitS.withLatestFrom(emailS, (_, String email) => email).share();

    final message$ = Rx.merge([
      submittedEmail$
          .where((email) => !Validator.isValidEmail(email))
          .map((_) => const SendEmailInvalidInformationMessage()),
      submittedEmail$.where(Validator.isValidEmail).exhaustMap(
        (email) {
          return send(
            email,
            sendResetPasswordEmail,
            isLoadingS,
          );
        },
      ),
    ]).share();

    return SendEmailBloc._(
      dispose: DisposeBag([emailS, submitS, isLoadingS]).dispose,
      emailChanged: trim.pipe(emailS.add),
      emailError$: emailError$,
      submit: () => submitS.add(null),
      message$: message$,
      isLoading$: isLoadingS,
    );
  }

  static Stream<SendEmailMessage> send(
    String email,
    SendResetPasswordEmailUseCase sendResetPasswordEmail,
    Sink<bool> isLoadingController,
  ) {
    return sendResetPasswordEmail(email)
        .doOn(
          listen: () => isLoadingController.add(true),
          cancel: () => isLoadingController.add(false),
        )
        .map(
          (result) => result.fold(
            (_) => const SendEmailSuccessMessage(),
            (error, message) => SendEmailErrorMessage(error, message),
          ),
        );
  }
}
