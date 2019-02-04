
import 'package:meta/meta.dart';

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

class InvalidInformationMessage implements LoginMessage {
  const InvalidInformationMessage();
}
