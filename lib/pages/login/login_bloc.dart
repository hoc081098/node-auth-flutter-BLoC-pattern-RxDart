import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/usecases/login_use_case.dart';
import 'package:node_auth/pages/login/login.dart';
import 'package:node_auth/utils/streams.dart';
import 'package:node_auth/utils/type_defs.dart';
import 'package:node_auth/utils/validators.dart';

// ignore_for_file: close_sinks

/// BLoC that handles validating form and login
class LoginBloc extends DisposeCallbackBaseBloc {
  /// Input functions
  final Function1<String, void> emailChanged;
  final Function1<String, void> passwordChanged;
  final Function0<void> submitLogin;

  /// Streams
  final Stream<String?> emailError$;
  final Stream<String?> passwordError$;
  final Stream<LoginMessage> message$;
  final Stream<bool> isLoading$;

  LoginBloc._({
    required Function0<void> dispose,
    required this.emailChanged,
    required this.passwordChanged,
    required this.submitLogin,
    required this.emailError$,
    required this.passwordError$,
    required this.message$,
    required this.isLoading$,
  }) : super(dispose);

  factory LoginBloc(final LoginUseCase login) {
    /// Controllers
    final emailController = PublishSubject<String>();
    final passwordController = PublishSubject<String>();
    final submitLoginController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>.seeded(false);
    final controllers = [
      emailController,
      passwordController,
      submitLoginController,
      isLoadingController,
    ];

    ///
    /// Streams
    ///

    final isValidSubmit$ = Rx.combineLatest3(
      emailController.stream.map(Validator.isValidEmail),
      passwordController.stream.map(Validator.isValidPassword),
      isLoadingController.stream,
      (bool isValidEmail, bool isValidPassword, bool isLoading) =>
          isValidEmail && isValidPassword && !isLoading,
    ).shareValueSeeded(false);

    final credential$ = Rx.combineLatest2(
      emailController.stream,
      passwordController.stream,
      (String email, String password) =>
          Credential(email: email, password: password),
    );

    final submit$ = submitLoginController.stream
        .withLatestFrom(isValidSubmit$, (_, bool isValid) => isValid)
        .share();

    final message$ = Rx.merge([
      submit$
          .where((isValid) => isValid)
          .withLatestFrom(credential$, (_, Credential c) => c)
          .exhaustMap(
            (credential) => login(
              email: credential.email,
              password: credential.password,
            )
                .doOn(
                  listen: () => isLoadingController.add(true),
                  cancel: () => isLoadingController.add(false),
                )
                .map(_responseToMessage),
          ),
      submit$
          .where((isValid) => !isValid)
          .map((_) => const InvalidInformationMessage())
    ]).share();

    final emailError$ = emailController.stream
        .map((email) {
          if (Validator.isValidEmail(email)) return null;
          return 'Invalid email address';
        })
        .distinct()
        .share();

    final passwordError$ = passwordController.stream
        .map((password) {
          if (Validator.isValidPassword(password)) return null;
          return 'Password must be at least 6 characters';
        })
        .distinct()
        .share();

    final subscriptions = <String, Stream>{
      'emailError': emailError$,
      'passwordError': passwordError$,
      'isValidSubmit': isValidSubmit$,
      'message': message$,
      'isLoading': isLoadingController,
    }.debug();

    return LoginBloc._(
      dispose: DisposeBag([...controllers, ...subscriptions]).dispose,
      emailChanged: trim.pipe(emailController.add),
      passwordChanged: passwordController.add,
      submitLogin: () => submitLoginController.add(null),
      emailError$: emailError$,
      passwordError$: passwordError$,
      message$: message$,
      isLoading$: isLoadingController,
    );
  }

  static LoginMessage _responseToMessage(UnitResult result) {
    return result.fold(
      ifRight: (_) => const LoginSuccessMessage(),
      ifLeft: (appError) => LoginErrorMessage(appError.message, appError.error),
    );
  }
}
