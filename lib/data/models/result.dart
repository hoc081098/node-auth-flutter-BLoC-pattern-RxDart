import 'package:meta/meta.dart';

@immutable
abstract class Result<T> {}

class Success<T> implements Result<T> {
  final T result;

  const Success(this.result);

  @override
  String toString() => 'Success{result: $result}';
}

class Failure<T> implements Result<T> {
  final String message;
  final Object error;

  const Failure(this.message, [this.error]);

  @override
  String toString() => 'Failure{message: $message, error: $error}';
}
