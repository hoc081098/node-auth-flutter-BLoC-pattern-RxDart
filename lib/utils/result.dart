import 'package:dart_either/dart_either.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

export 'package:dart_either/dart_either.dart';

class AppError {
  final String message;
  final Object error;
  final StackTrace stackTrace;

  AppError({
    required this.message,
    required this.error,
    required this.stackTrace,
  });

  @override
  String toString() =>
      'AppError{message: $message, error: $error, stackTrace: $stackTrace}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          error == other.error &&
          stackTrace == other.stackTrace;

  @override
  int get hashCode => Object.hash(message, error, stackTrace);
}

extension FlatMapResultExtension<T extends Object?> on Single<Result<T>> {
  Single<Result<R>> flatMapResult<R>(
    Single<Result<R>> Function(T value) mapper,
  ) =>
      flatMapSingle(
        (result) => result.when(
          ifRight: (v) => mapper(v.value),
          ifLeft: (l) => Single.value(l),
        ),
      );
}

extension UnitSingleResultExtension<T> on Single<Result<T>> {
  UnitResultSingle asUnit() => map((r) => r.map((_) => Unit.instance));
}

typedef Result<T> = Either<AppError, T>;
typedef UnitResult = Result<Unit>;
typedef UnitResultSingle = Single<UnitResult>;

class Unit {
  const Unit._();

  static const instance = Unit._();
}
