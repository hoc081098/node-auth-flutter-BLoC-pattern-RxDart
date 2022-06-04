import 'package:dart_either/dart_either.dart';
import 'package:node_auth/utils/unit.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

export 'package:dart_either/dart_either.dart';
export 'package:rxdart_ext/rxdart_ext.dart';

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

typedef Result<T> = Either<AppError, T>;
typedef UnitResult = Result<Unit>;
typedef UnitResultSingle = Single<UnitResult>;
