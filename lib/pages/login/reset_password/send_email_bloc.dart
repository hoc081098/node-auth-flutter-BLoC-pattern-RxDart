// ignore_for_file: close_sinks

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/pages/login/reset_password/send_email.dart';
import 'package:node_auth/utils/validators.dart';
import 'package:rxdart/rxdart.dart';

class SendEmailBloc {
  ///
  ///
  ///
  final void Function() submit;
  final void Function(String) emailChanged;

  ///
  ///
  ///
  final Stream<String> emailError$;
  final Stream<SendEmailMessage> message$;
  final ValueObservable<bool> isLoading$;

  ///
  ///
  ///
  final void Function() dispose;

  const SendEmailBloc._({
    @required this.submit,
    @required this.emailChanged,
    @required this.emailError$,
    @required this.message$,
    @required this.isLoading$,
    @required this.dispose,
  });

  factory SendEmailBloc(UserRepository userRepository) {
    assert(userRepository != null);

    final emailController = PublishSubject<String>();
    final submitController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>(seedValue: false);

    final emailError$ = emailController.map((email) {
      if (Validator.isValidEmail(email)) return null;
      return 'Invalid email address';
    }).share();

    final submit$ = submitController
        .withLatestFrom(emailController, (_, String email) => email)
        .share();

    final sendResult$ = submit$.where(Validator.isValidEmail).exhaustMap(
        (email) => send(email, userRepository, isLoadingController));
    final message$ = Observable.merge([
      submit$
          .where((email) => !Validator.isValidEmail(email))
          .map((_) => const SendEmailInvalidInformationMessage()),
      sendResult$,
    ]).share();

    return SendEmailBloc._(
      dispose: () async {
        await Future.wait(<StreamController>[
          emailController,
          submitController,
          isLoadingController,
        ].map((c) => c.close()));
      },
      emailChanged: emailController.add,
      emailError$: emailError$,
      submit: () => submitController.add(null),
      message$: message$,
      isLoading$: isLoadingController,
    );
  }

  static Stream<SendEmailMessage> send(
    String email,
    UserRepository userRepository,
    Sink<bool> isLoadingController,
  ) {
    SendEmailMessage _resultToMessage(result) {
      if (result is Success) {
        return const SendEmailSuccessMessage();
      }
      if (result is Failure) {
        return SendEmailErrorMessage(result.message, result.error);
      }
      return SendEmailErrorMessage('An error occurred!');
    }

    return userRepository
        .sendResetPasswordEmail(email)
        .doOnListen(() => isLoadingController.add(true))
        .doOnData((_) => isLoadingController.add(false))
        .map(_resultToMessage);
  }
}
