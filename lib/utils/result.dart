import 'package:built_value/built_value.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'result.g.dart';

@sealed
@immutable
abstract class Result<T> {}

extension ResultExtensions<T> on Result<T> {
  R fold<R>(
    R Function(T? value) onSuccess,
    R Function(Object error, String message) onFailure,
  ) {
    final self = this;
    if (self is Success<T>) {
      return onSuccess(self.value);
    }
    if (self is Failure<T>) {
      return onFailure(self.error, self.message);
    }
    throw StateError('Cannot handle $this');
  }
}

abstract class Success<T>
    implements Built<Success<T>, SuccessBuilder<T>>, Result<T> {
  T? get value;

  Success._();

  factory Success.of({required T? value}) = _$Success._;

  factory Success([void Function(SuccessBuilder<T>) updates]) = _$Success<T>;
}

abstract class Failure<T>
    implements Built<Failure<T>, FailureBuilder<T>>, Result<T> {
  String get message;

  Object get error;

  Failure._();

  factory Failure.of({
    required String message,
    required Object error,
  }) = _$Failure._;

  factory Failure([void Function(FailureBuilder<T>) updates]) = _$Failure<T>;
}

extension FlatMapResultExtension<T> on Stream<Result<T>> {
  Stream<Result<R>> flatMapResult<R>(
      Stream<Result<R>> Function(T? value) mapper) {
    return flatMap((result) {
      if (result is Failure<T>) {
        final failure = Failure<R>.of(
          message: result.message,
          error: result.error,
        );
        return Stream.value(failure);
      }
      if (result is Success<T>) {
        return mapper(result.value);
      }
      return Stream.error('Cannot handle result: $result');
    });
  }
}
