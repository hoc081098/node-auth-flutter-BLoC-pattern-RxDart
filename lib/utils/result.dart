import 'package:built_value/built_value.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'result.g.dart';

@immutable
abstract class Result<T> {}

abstract class Success<T>
    implements Built<Success<T>, SuccessBuilder<T>>, Result<T> {
  @nullable
  T get result;

  Success._();

  factory Success([void Function(SuccessBuilder<T>) updates]) = _$Success<T>;
}

abstract class Failure<T>
    implements Built<Failure<T>, FailureBuilder<T>>, Result<T> {
  String get message;

  @nullable
  Object get error;

  Failure._();

  factory Failure([void Function(FailureBuilder<T>) updates]) = _$Failure<T>;
}

extension FlatMapResultExtension<T> on Stream<Result<T>> {
  Stream<Result<R>> flatMapResult<R>(Stream<Result<R>> Function(T result) mapper) {
    ArgumentError.checkNotNull(mapper, 'mapper');
    return flatMap((result) {
      if (result is Failure<T>) {
        final failure = Failure<R>((b) => b
          ..message = result.message
          ..error = result.error);
        return Stream.value(failure);
      }
      if (result is Success<T>) {
        return mapper(result.result);
      }
      return Stream.error('Cannot handle result: $result');
    });
  }
}
