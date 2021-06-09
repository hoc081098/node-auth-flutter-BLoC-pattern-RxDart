import 'package:meta/meta.dart';

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

  const RegisterErrorMessage(this.message, this.error);
}

class RegisterSuccessMessage implements RegisterMessage {
  final String email;

  const RegisterSuccessMessage(this.email);
}
