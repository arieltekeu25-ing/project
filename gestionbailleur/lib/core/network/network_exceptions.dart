/// Exceptions réseau de l'application
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Exceptions spécifiques
class BadRequestException extends NetworkException {
  BadRequestException(super.message) : super(statusCode: 400);
}

class UnauthorizedException extends NetworkException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends NetworkException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

class NotFoundException extends NetworkException {
  NotFoundException(super.message) : super(statusCode: 404);
}

class ServerException extends NetworkException {
  ServerException(super.message) : super(statusCode: 500);
}

class NetworkTimeoutException extends NetworkException {
  NetworkTimeoutException(super.message);
}

class NoInternetException extends NetworkException {
  NoInternetException(super.message);
}
