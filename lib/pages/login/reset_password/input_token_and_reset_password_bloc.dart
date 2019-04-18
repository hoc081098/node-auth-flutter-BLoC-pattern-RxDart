import 'dart:async';

import 'package:meta/meta.dart';
import 'package:node_auth/data/data.dart';
import 'package:node_auth/utils/validators.dart';
import 'package:rxdart/rxdart.dart';
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
  final error;

  const ResetPasswordFailure(this.message, [this.error]);
}

//ignore_for_file: close_sinks

class InputTokenAndResetPasswordBloc {
  final void Function(String) emailChanged;
  final void Function(String) passwordChanged;
  final void Function(String) tokenChanged;
  final void Function() submit;

  final Stream<String> emailError$;
  final Stream<String> passwordError$;
  final Stream<String> tokenError$;
  final Stream<bool> isLoading$;
  final Stream<InputTokenAndResetPasswordMessage> message$;

  final void Function() dispose;

  InputTokenAndResetPasswordBloc._({
    @required this.emailChanged,
    @required this.passwordChanged,
    @required this.tokenChanged,
    @required this.emailError$,
    @required this.passwordError$,
    @required this.tokenError$,
    @required this.dispose,
    @required this.submit,
    @required this.isLoading$,
    @required this.message$,
  });

  factory InputTokenAndResetPasswordBloc(final UserRepository userRepository) {
    assert(userRepository != null);

    final emailSubject = BehaviorSubject<String>.seeded('');
    final tokenSubject = BehaviorSubject<String>.seeded('');
    final passwordSubject = BehaviorSubject<String>.seeded('');
    final submitSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

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

    allFieldsAreValid(Tuple3<String, String, String> tuple3) {
      return Validator.isValidEmail(tuple3.item1) &&
          tuple3.item2.isNotEmpty &&
          Validator.isValidPassword(tuple3.item3);
    }

    final message$ = Observable.merge([
      allField$
          .where((tuple3) => !allFieldsAreValid(tuple3))
          .map((_) => const InvalidInformation()),
      allField$
          .where(allFieldsAreValid)
          .exhaustMap((tuple3) => _sendResetPasswordRequest(
                userRepository,
                tuple3,
                isLoadingSubject,
              )),
    ]).share();

    ///
    ///
    ///
    final subsciptions = <StreamSubscription>[];
    final subjects = <Subject>[
      emailSubject,
      tokenSubject,
      passwordSubject,
      submitSubject,
    ];
    return InputTokenAndResetPasswordBloc._(
      dispose: () async {
        await Future.wait(subsciptions.map((s) => s.cancel()));
        await Future.wait(subjects.map((s) => s.close()));
      },
      emailChanged: emailSubject.add,
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
    UserRepository repository,
    Tuple3<String, String, String> tuple3,
    Sink<bool> isLoadingSink,
  ) async* {
    _toMessage([result, String email]) {
      if (result is Success) {
        return ResetPasswordSuccess(email);
      }
      if (result is Failure) {
        return ResetPasswordFailure(result.message, result.error);
      }
      return ResetPasswordFailure('An error occurred!');
    }

    isLoadingSink.add(true);
    try {
      final result = await repository
          .resetPassword(
            email: tuple3.item1,
            token: tuple3.item2,
            newPassword: tuple3.item3,
          )
          .first;
      yield _toMessage(result, tuple3.item1);
    } catch (e) {
      yield _toMessage();
    } finally {
      isLoadingSink.add(false);
    }
  }
}
