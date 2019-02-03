import 'dart:async';

import 'package:meta/meta.dart';
import 'package:node_auth/data/data.dart';
import 'package:rxdart/rxdart.dart';

///
///
///

class Validator {
  Validator._();

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidEmail(String email) {
    final _emailRegExpString = r'[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9]'
        r'[a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+';
    return RegExp(_emailRegExpString, caseSensitive: false).hasMatch(email);
  }
}

///
/// Login message
///

class Credential {
  final String email;
  final String password;

  const Credential({this.email, this.password});
}

@immutable
abstract class LoginMessage {}

class LoginSuccessMessage implements LoginMessage {
  const LoginSuccessMessage();
}

class LoginErrorMessage implements LoginMessage {
  final Object error;
  final String message;

  const LoginErrorMessage(this.message, [this.error]);

  @override
  String toString() => 'LoginErrorMessage{message=$message, error=$error}';
}

///
/// BLoC handle validate form and login
///
class LoginBloc {
  ///
  /// Input functions
  ///
  final void Function(String) emailChanged;
  final void Function(String) passwordChanged;
  final void Function() submitLogin;

  ///
  /// Streams
  ///
  final Stream<String> emailError$;
  final Stream<String> passwordError$;
  final ValueObservable<bool> isValidSubmit$;
  final Stream<LoginMessage> message$;

  ///
  /// Clean up
  ///
  final void Function() dispose;

  LoginBloc._({
    @required this.emailChanged,
    @required this.passwordChanged,
    @required this.submitLogin,
    @required this.emailError$,
    @required this.passwordError$,
    @required this.message$,
    @required this.isValidSubmit$,
    @required this.dispose,
  });

  factory LoginBloc(UserRepository userRepository) {
    assert(userRepository != null);

    ///
    /// Controllers
    ///
    final emailController = PublishSubject<String>(); // ignore: close_sinks
    final passwordController = PublishSubject<String>(); // ignore: close_sinks
    final submitLoginController = PublishSubject<void>(); // ignore: close_sinks
    final controllers = <StreamController>[
      emailController,
      passwordController,
      submitLoginController,
    ];

    ///
    /// Streams
    ///

    final isValidSubmit$ = Observable.combineLatest2(
      emailController.stream.map(Validator.isValidEmail),
      passwordController.stream.map(Validator.isValidPassword),
      (isValidEmail, isValidPassword) => isValidEmail && isValidPassword,
    ).shareValue(seedValue: false);

    final credential$ = Observable.combineLatest2(
      emailController.stream,
      passwordController.stream,
      (email, password) => Credential(email: email, password: password),
    );

    final message$ = submitLoginController.stream
        .withLatestFrom(isValidSubmit$, (_, bool isValid) => isValid)
        .where((isValid) => isValid)
        .withLatestFrom(credential$, (_, Credential c) => c)
        .exhaustMap((credential) => userRepository
            .login(
              email: credential.email,
              password: credential.password,
            )
            .map(_responseToMessage))
        .share();

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

    final streams = <String, Stream>{
      'emailError': emailError$,
      'passwordError': passwordError$,
      'isValidSubmit': isValidSubmit$,
      'message': message$,
    };
    final subscriptions = streams.keys
        .map((tag) =>
            streams[tag].listen((data) => print('[DEBUG] [$tag] = $data')))
        .toList();

    return LoginBloc._(
      emailChanged: emailController.add,
      passwordChanged: passwordController.add,
      submitLogin: () => submitLoginController.add(null),
      emailError$: emailError$,
      passwordError$: passwordError$,
      message$: message$,
      isValidSubmit$: isValidSubmit$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
    );
  }

  static LoginMessage _responseToMessage(Result result) {
    if (result is Success) {
      return const LoginSuccessMessage();
    }
    if (result is Failure) {
      return LoginErrorMessage(result.message, result.error);
    }
    return LoginErrorMessage("Unknown result $result");
  }
}
