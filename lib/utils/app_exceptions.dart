class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException({required this.message, this.prefix});

  @override
  String toString() {
    return "$prefix$message";
  }
}

class ApiException extends AppException {
  final int statusCode;

  ApiException({
    required this.statusCode,
    required String message,
    String prefix = 'API Error: '
  }) : super(message: message, prefix: prefix);
}

class NetworkException extends AppException {
  NetworkException({required String message})
      : super(message: message, prefix: 'Network Error: ');
}

class TimeoutException extends AppException {
  TimeoutException({required String message})
      : super(message: message, prefix: 'Timeout Error: ');
}
