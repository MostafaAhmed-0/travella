import 'package:equatable/equatable.dart';
import '../../../../data/models/profile_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized auth state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading during sign-in or session check
class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Authenticated user with role
class Authenticated extends AuthState {
  final ProfileModel profile;

  const Authenticated(this.profile);

  bool get isAdmin => profile.isAdmin;
  bool get isStaff => profile.isStaff;
  bool get hasAdminAccess => profile.hasAdminAccess;

  @override
  List<Object?> get props => [profile];
}

/// Unauthenticated / Guest state
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication error (invalid credentials, network error, unauthorized role)
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
