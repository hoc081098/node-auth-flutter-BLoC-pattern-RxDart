import 'dart:async';

import 'package:meta/meta.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/pages/register/register.dart';
import 'package:rxdart/rxdart.dart';

///
/// BLoC handle validate form and register
///
class RegisterBloc {
  ///
  /// Input functions
  ///
  final void Function(String) nameChanged;
  final void Function(String) emailChanged;
  final void Function(String) passwordChanged;
  final void Function() submitRegister;

  ///
  /// Streams
  ///
  final Stream<String> emailError$;
  final Stream<String> passwordError$;
  final Stream<String> nameError$;
  final Stream<RegisterMessage> message$;
  final Stream<bool> isLoading$;

  ///
  /// Clean up
  ///
  final void Function() dispose;

  RegisterBloc._({
    @required this.emailChanged,
    @required this.passwordChanged,
    @required this.submitRegister,
    @required this.emailError$,
    @required this.passwordError$,
    @required this.message$,
    @required this.dispose,
    @required this.isLoading$,
    @required this.nameChanged,
    @required this.nameError$,
  });

  factory RegisterBloc(UserRepository userRepository) {
    assert(userRepository != null);

    ///
    /// Controllers
    ///
    final emailController = PublishSubject<String>(); // ignore: close_sinks
    final nameController = PublishSubject<String>(); // ignore: close_sinks
    final passwordController = PublishSubject<String>(); // ignore: close_sinks
    // ignore: close_sinks
    final submitRegisterController = PublishSubject<void>();
    // ignore: close_sinks
    final isLoadingController = BehaviorSubject<bool>(seedValue: false);
    final controllers = <StreamController>[
      emailController,
      nameController,
      passwordController,
      submitRegisterController,
      isLoadingController,
    ];

    ///
    /// Streams
    ///

    final isValidSubmit$ = Observable.combineLatest4(
      emailController.stream.map(Validator.isValidEmail),
      passwordController.stream.map(Validator.isValidPassword),
      isLoadingController.stream,
      nameController.stream.map(Validator.isValidUserName),
      (isValidEmail, isValidPassword, isLoading, isValidName) {
        return isValidEmail && isValidPassword && !isLoading && isValidName;
      },
    ).shareValue(seedValue: false);

    final registerUser$ = Observable.combineLatest3(
      emailController.stream,
      passwordController.stream,
      nameController.stream,
      (email, password, name) => RegisterUser(email, name, password),
    );

    final submit$ = submitRegisterController.stream
        .withLatestFrom(isValidSubmit$, (_, bool isValid) => isValid)
        .share();

    final message$ = Observable.merge([
      submit$
          .where((isValid) => isValid)
          .withLatestFrom(registerUser$, (_, RegisterUser user) => user)
          .exhaustMap(
            (user) => userRepository
                .registerUser(
                  email: user.email,
                  password: user.password,
                  name: user.name,
                )
                .doOnListen(() => isLoadingController.add(true))
                .doOnData((_) => isLoadingController.add(false))
                .map((result) => _responseToMessage(result, user.email)),
          ),
      submit$
          .where((isValid) => !isValid)
          .map((_) => const RegisterInvalidInformationMessage())
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

    final nameError$ = nameController.stream
        .map((name) {
          if (Validator.isValidUserName(name)) return null;
          return 'Name must be at least 3 characters';
        })
        .distinct()
        .share();

    final streams = <String, Stream>{
      'emailError': emailError$,
      'passwordError': passwordError$,
      'nameError': nameError$,
      'isValidSubmit': isValidSubmit$,
      'message': message$,
      'isLoading': isLoadingController,
    };
    final subscriptions = streams.keys.map((tag) {
      return streams[tag].listen((data) {
        print('[DEBUG] [$tag] = $data');
      });
    }).toList();

    return RegisterBloc._(
      emailChanged: emailController.add,
      passwordChanged: passwordController.add,
      submitRegister: () => submitRegisterController.add(null),
      emailError$: emailError$,
      passwordError$: passwordError$,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
      isLoading$: isLoadingController,
      nameChanged: nameController.add,
      nameError$: nameError$,
    );
  }

  static RegisterMessage _responseToMessage(Result result, String email) {
    if (result is Success) {
      return RegisterSuccessMessage(email);
    }
    if (result is Failure) {
      return RegisterErrorMessage(result.message, result.error);
    }
    return RegisterErrorMessage("Unknown result $result");
  }
}
