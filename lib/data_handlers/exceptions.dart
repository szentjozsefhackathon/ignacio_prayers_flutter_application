class NoLocalDataException implements Exception {
  NoLocalDataException(this.message);

  final String message;

  @override
  String toString() => 'NoLocalDataException: $message';
}

class DataLoadingException implements Exception {
  DataLoadingException(this.message, [this.originalException]);

  final String message;
  final Object? originalException;

  @override
  String toString() =>
      'DataLoadingException: $message, caused by $originalException';
}
