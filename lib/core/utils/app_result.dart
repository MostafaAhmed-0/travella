/// Sealed class for representing async data states
sealed class AppResult<T> {
  const AppResult();
}

class AppSuccess<T> extends AppResult<T> {
  final T data;
  const AppSuccess(this.data);
}

class AppFailure<T> extends AppResult<T> {
  final String message;
  final Object? error;
  const AppFailure(this.message, {this.error});
}

class AppLoading<T> extends AppResult<T> {
  const AppLoading();
}

// ── Base State ────────────────────────────────────────────────────────────────
abstract class BaseState {}

class InitialState extends BaseState {}

class LoadingState extends BaseState {}

class EmptyState extends BaseState {}

class ErrorState extends BaseState {
  final String message;
  ErrorState(this.message);
}

// ── Failure ───────────────────────────────────────────────────────────────────
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Check your connection.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication error.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
