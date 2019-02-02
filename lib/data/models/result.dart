import 'package:meta/meta.dart';

@immutable
abstract class Result {}

class Success implements Result {
  final String message;

  const Success([this.message]);
}

class Failure implements Result {
  final String message;
  final Object error;

  const Failure(this.message, [this.error]);
}
