class NoLocalDataException implements Exception {
  final String message;
  NoLocalDataException(this.message);

  @override
  String toString() => 'NoLocalDataException: $message';
}

class DataLoadingException implements Exception {
  final String message;
  final Object? originalException;

  DataLoadingException(this.message, [this.originalException]);

  @override
  String toString() => 'DataLoadingException: $message, caused by $originalException';
}