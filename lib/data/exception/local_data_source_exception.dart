class LocalDataSourceException implements Exception {
  final String message;
  final Object error;
  final StackTrace stackTrace;

  const LocalDataSourceException(this.message, this.error, this.stackTrace);

  @override
  String toString() =>
      'LocalDataSourceException{message=$message, error=$error, stackTrace=$stackTrace}';
}
