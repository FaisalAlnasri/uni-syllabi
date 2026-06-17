sealed class Result<T, F> {
  const Result();
}

final class Success<T, F> extends Result<T, F> {
  final T data;
  const Success(this.data);
}

final class Failure<T, F> extends Result<T, F> {
  final F error;
  const Failure(this.error);
}

extension ResultExtensions<T, F> on Result<T, F> {
  bool get isSuccess => this is Success<T, F>;
  bool get isFailure => this is Failure<T, F>;

  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  F? get errorOrNull => switch (this) {
        Failure(:final error) => error,
        Success() => null,
      };

  /// Run [onSuccess] or [onFailure] and return a value.
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(F error) onFailure,
  }) =>
      switch (this) {
        Success(:final data) => onSuccess(data),
        Failure(:final error) => onFailure(error),
      };

  /// Transform the success value, pass failures through unchanged.
  Result<R, F> map<R>(R Function(T data) transform) => switch (this) {
        Success(:final data) => Success(transform(data)),
        Failure(:final error) => Failure(error),
      };
}