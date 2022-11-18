class RemoteDataSourceException implements Exception {
  final String message;
  final Object error;
  final StackTrace stackTrace;

  const RemoteDataSourceException(this.message, this.error, this.stackTrace);

  @override
  String toString() =>
      'RemoteDataSourceException{message=$message, error=$error, stackTrace=$stackTrace}';
}
