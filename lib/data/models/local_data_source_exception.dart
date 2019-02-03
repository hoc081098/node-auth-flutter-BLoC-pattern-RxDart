class LocalDataSourceException implements Exception {
  final String message;
  final Object error;

  const LocalDataSourceException(this.message, [this.error]);

  @override
  String toString() => 'LocalDataSourceException{message=$message, error=$error}';
}
