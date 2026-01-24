import 'failures.dart';

abstract class Exceptions implements Exception {
  final String message;

  Exceptions(this.message);
}

class ServerException extends Exceptions {
  final int? statusCode;
  ServerException(super.message, {this.statusCode});
}

class NetworkException extends Exceptions {
  NetworkException(super.message);
}

class CacheException extends Exceptions {
  CacheException(super.message);
}

class ValidationException extends Exceptions {
  ValidationException(super.message);
}

class AuthenticationException extends Exceptions {
  AuthenticationException(super.message);
}

class AuthorizationException extends Exceptions {
  AuthorizationException(super.message);
}

class HttpErrorHandler {
  static String getExceptionMessage(int? statusCode, String operation) {
    if (statusCode == null) {
      return 'Unable to connect to server while $operation. Please check your internet connection.';
    }

    switch (statusCode) {
      case 200:
        return 'Request successful';
      case 201:
        return 'Resource created successfully';
      case 204:
        return 'No content available';
      case 400:
        return 'Invalid request data provided for $operation. Please check your input.';
      case 401:
        return 'Authentication required. Please log in to access $operation.';
      case 403:
        return 'Access denied. You don\'t have permission to $operation.';
      case 404:
        return 'The requested resource for $operation was not found. It may have been moved or deleted.';
      case 409:
        return 'Conflict occurred while $operation. The resource may already exist or be in use.';
      case 422:
        return 'Unable to process the request for $operation due to validation errors.';
      case 429:
        return 'Too many requests. Please wait a moment before trying $operation again.';
      case 500:
        return 'Internal server error occurred while $operation. Please try again later.';
      case 502:
        return 'Bad gateway error while $operation. The server is temporarily unavailable.';
      case 503:
        return 'Service temporarily unavailable for $operation. Please try again later.';
      case 504:
        return 'Gateway timeout while $operation. The server took too long to respond.';
      default:
        return 'An unexpected error (Status: $statusCode) occurred while $operation. Please try again.';
    }
  }
}

/// Utility class for mapping exceptions to failures
class ExceptionMapper {
  /// Maps any exception to its corresponding failure
  static Failure toFailure(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else if (exception is AuthenticationException) {
      return AuthenticationFailure(exception.message);
    } else if (exception is AuthorizationException) {
      return AuthorizationFailure(exception.message);
    } else {
      return UnexpectedFailure(exception.toString());
    }
  }
}
