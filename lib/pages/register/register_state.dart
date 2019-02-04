import 'package:meta/meta.dart';

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

  static bool isValidUserName(String userName) {
    return userName.length >= 3;
  }
}

@immutable
class RegisterUser {
  final String email;
  final String name;
  final String password;

  const RegisterUser(this.email, this.name, this.password);
}

@immutable
abstract class RegisterMessage {}

class RegisterInvalidInformationMessage implements RegisterMessage {
  const RegisterInvalidInformationMessage();
}

class RegisterErrorMessage implements RegisterMessage {
  final String message;
  final Object error;

  const RegisterErrorMessage(this.message, [this.error]);
}

class RegisterSuccessMessage implements RegisterMessage {
  final String email;

  const RegisterSuccessMessage(this.email);
}
