import 'package:dart_either/dart_either.dart';
import 'package:http_client_hoc081098/http_client_hoc081098.dart';
import 'package:meta/meta.dart';
import 'package:node_auth/utils/unit.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

export 'package:dart_either/dart_either.dart';
export 'package:rxdart_ext/rxdart_ext.dart';

@sealed
class AppError {
  final String? _message;
  final Object? _error;
  final StackTrace? _stackTrace;

  /// Message of error
  /// Returns null if [isCancellation] is true
  String? get message => isCancellation ? null : _message;

  /// Get caused error
  /// Returns null if [isCancellation] is true
  Object? get error => isCancellation ? null : _error;

  /// Get stack trace
  /// Returns null if [isCancellation] is true
  StackTrace? get stackTrace => isCancellation ? null : _stackTrace;

  /// Returns true if this error is caused by cancellation
  bool get isCancellation => this is AppCancellationError;

  const AppError._(
    this._message,
    this._error,
    this._stackTrace,
  );

  factory AppError({
    required String message,
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (error is CancellationException) {
      return const AppCancellationError();
    }

    return AppError._(
      message,
      error,
      stackTrace,
    );
  }

  @override
  String toString() =>
      'AppError{message: $_message, error: $_error, stackTrace: $_stackTrace}';
}

class AppCancellationError extends AppError {
  const AppCancellationError() : super._(null, null, null);

  @override
  String toString() => 'AppCancellationError';
}

typedef Result<T> = Either<AppError, T>;
typedef UnitResult = Result<Unit>;
typedef UnitResultSingle = Single<UnitResult>;
