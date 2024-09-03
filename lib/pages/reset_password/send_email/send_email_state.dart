import 'package:meta/meta.dart';

@immutable
sealed class SendEmailMessage {}

class SendEmailInvalidInformationMessage implements SendEmailMessage {
  const SendEmailInvalidInformationMessage();
}

class SendEmailSuccessMessage implements SendEmailMessage {
  const SendEmailSuccessMessage();
}

class SendEmailErrorMessage implements SendEmailMessage {
  final String message;
  final Object error;

  const SendEmailErrorMessage(this.error, this.message);
}
