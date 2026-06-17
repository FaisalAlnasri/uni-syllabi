sealed class AppError {
  final String message;
  final Object? originalException;

  const AppError({
    required this.message,
    this.originalException,
  });

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkError extends AppError {
  final int? statusCode;

  const NetworkError({
    required super.message,
    this.statusCode,
    super.originalException,
  });
}

final class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.originalException,
  });
}

final class CacheError extends AppError {
  const CacheError({
    required super.message,
    super.originalException,
  });
}

final class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    super.originalException,
  });
}

final class UnknownError extends AppError {
  const UnknownError({
    super.message = 'An unexpected error occurred.',
    super.originalException,
  });
}