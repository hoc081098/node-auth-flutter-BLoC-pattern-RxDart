import 'dart:async';

import 'package:disposebag/disposebag.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:node_auth/domain/models/app_error.dart';
import 'package:node_auth/domain/usecases/register_use_case.dart';
import 'package:node_auth/pages/register/register.dart';
import 'package:node_auth/utils/streams.dart';
import 'package:node_auth/utils/type_defs.dart';
import 'package:node_auth/utils/validators.dart';

// ignore_for_file: close_sinks

/// BLoC handles validating form and register
class RegisterBloc extends DisposeCallbackBaseBloc {
  /// Input functions
  final Function1<String, void> nameChanged;
  final Function1<String, void> emailChanged;
  final Function1<String, void> passwordChanged;
  final Function0<void> submitRegister;

  /// Streams
  final Stream<String?> emailError$;
  final Stream<String?> passwordError$;
  final Stream<String?> nameError$;
  final Stream<RegisterMessage> message$;
  final Stream<bool> isLoading$;

  RegisterBloc._({
    required Function0<void> dispose,
    required this.emailChanged,
    required this.passwordChanged,
    required this.submitRegister,
    required this.emailError$,
    required this.passwordError$,
    required this.message$,
    required this.isLoading$,
    required this.nameChanged,
    required this.nameError$,
  }) : super(dispose);

  factory RegisterBloc(final RegisterUseCase registerUser) {
    /// Controllers
    final emailController = PublishSubject<String>();
    final nameController = PublishSubject<String>();
    final passwordController = PublishSubject<String>();
    final submitRegisterController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>.seeded(false);
    final controllers = [
      emailController,
      nameController,
      passwordController,
      submitRegisterController,
      isLoadingController,
    ];

    ///
    /// Streams
    ///

    final isValidSubmit$ = Rx.combineLatest4(
      emailController.stream.map(Validator.isValidEmail),
      passwordController.stream.map(Validator.isValidPassword),
      isLoadingController.stream,
      nameController.stream.map(Validator.isValidUserName),
      (bool isValidEmail, bool isValidPassword, bool isLoading,
              bool isValidName) =>
          isValidEmail && isValidPassword && !isLoading && isValidName,
    ).shareValueSeeded(false);

    final registerUser$ = Rx.combineLatest3(
      emailController.stream,
      passwordController.stream,
      nameController.stream,
      (String email, String password, String name) =>
          RegisterUser(email, name, password),
    );

    final submit$ = submitRegisterController.stream
        .withLatestFrom(isValidSubmit$, (_, bool isValid) => isValid)
        .share();

    final message$ = Rx.merge([
      submit$
          .where((isValid) => isValid)
          .withLatestFrom(registerUser$, (_, RegisterUser user) => user)
          .exhaustMap(
            (user) => registerUser(
              email: user.email,
              password: user.password,
              name: user.name,
            )
                .doOn(
                  listen: () => isLoadingController.add(true),
                  cancel: () => isLoadingController.add(false),
                )
                .map((result) => _responseToMessage(result, user.email)),
          ),
      submit$
          .where((isValid) => !isValid)
          .map((_) => const RegisterInvalidInformationMessage())
    ]).whereNotNull().share();

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

    final nameError$ = nameController.stream
        .map((name) {
          if (Validator.isValidUserName(name)) return null;
          return 'Name must be at least 3 characters';
        })
        .distinct()
        .share();

    final subscriptions = <String, Stream>{
      'emailError': emailError$,
      'passwordError': passwordError$,
      'nameError': nameError$,
      'isValidSubmit': isValidSubmit$,
      'message': message$,
      'isLoading': isLoadingController,
    }.debug();

    return RegisterBloc._(
      dispose: DisposeBag([...subscriptions, ...controllers]).dispose,
      nameChanged: trim.pipe(nameController.add),
      emailChanged: trim.pipe(emailController.add),
      passwordChanged: passwordController.add,
      submitRegister: () => submitRegisterController.add(null),
      emailError$: emailError$,
      passwordError$: passwordError$,
      message$: message$,
      isLoading$: isLoadingController,
      nameError$: nameError$,
    );
  }

  static RegisterMessage? _responseToMessage(UnitResult result, String email) {
    return result.fold(
      ifRight: (_) => RegisterSuccessMessage(email),
      ifLeft: (appError) => appError.isCancellation
          ? null
          : RegisterErrorMessage(appError.message!, appError.error!),
    );
  }
}
