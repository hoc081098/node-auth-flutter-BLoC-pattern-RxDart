import 'package:dart_either/dart_either.dart';
import 'package:http_client_hoc081098/http_client_hoc081098.dart';
import 'package:meta/meta.dart';
import 'package:node_auth/utils/unit.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

export 'package:dart_either/dart_either.dart';
export 'package:rxdart_ext/rxdart_ext.dart';

@sealed
class AppError {
  final String message;
  final Object error;
  final StackTrace stackTrace;

  const AppError._({
    required this.message,
    required this.error,
    required this.stackTrace,
  });

  factory AppError({
    required String message,
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (error is CancellationException) {
      return const AppCancellationError();
    }

    return AppError._(
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

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

class AppCancellationError extends AppError {
  const AppCancellationError()
      : super._(
            message: 'CancellationException',
            error: const CancellationException(),
            stackTrace: StackTrace.empty);
}

typedef Result<T> = Either<AppError, T>;
typedef UnitResult = Result<Unit>;
typedef UnitResultSingle = Single<UnitResult>;
