import 'package:meta/meta.dart';

@immutable
sealed class HomeMessage {}

sealed class LogoutMessage implements HomeMessage {}

sealed class UpdateAvatarMessage implements HomeMessage {}

///
///
///
class LogoutSuccessMessage implements LogoutMessage {
  const LogoutSuccessMessage();
}

class LogoutErrorMessage implements LogoutMessage {
  final String message;
  final Object error;

  const LogoutErrorMessage(this.message, this.error);

  @override
  String toString() => 'LogoutErrorMessage{message: $message, error: $error}';
}

///
///
///
class UpdateAvatarSuccessMessage implements UpdateAvatarMessage {
  const UpdateAvatarSuccessMessage();
}

class UpdateAvatarErrorMessage implements UpdateAvatarMessage {
  final String message;
  final Object error;

  const UpdateAvatarErrorMessage(this.message, this.error);

  @override
  String toString() =>
      'UpdateAvatarErrorMessage{message: $message, error: $error}';
}
