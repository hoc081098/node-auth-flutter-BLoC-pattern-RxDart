import 'package:meta/meta.dart';

///
/// Login message
///

class Credential {
  final String email;
  final String password;

  const Credential({required this.email, required this.password});
}

@immutable
sealed class LoginMessage {}

class LoginSuccessMessage implements LoginMessage {
  const LoginSuccessMessage();
}

class LoginErrorMessage implements LoginMessage {
  final Object error;
  final String message;

  const LoginErrorMessage(this.message, this.error);

  @override
  String toString() => 'LoginErrorMessage{message=$message, error=$error}';
}

class InvalidInformationMessage implements LoginMessage {
  const InvalidInformationMessage();
}
