import 'package:built_value/built_value.dart';
import 'package:meta/meta.dart';

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
