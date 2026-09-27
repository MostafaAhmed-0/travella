import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/profile_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription = _authRepository.authStateChanges.listen((data) {
      if (data.session == null) {
        if (state is! Unauthenticated) {
          emit(const Unauthenticated());
        }
      }
    });
  }

  /// Check current user session on app start
  Future<void> checkAuth() async {
    emit(const AuthLoading(message: 'Checking authentication...'));
    try {
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        final profile = await _authRepository.getCurrentProfile();
        if (profile != null) {
          emit(Authenticated(profile));
          return;
        }
      }
      emit(const Unauthenticated());
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  /// Sign in with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading(message: 'Authenticating...'));
    try {
      final profile = await _authRepository.signIn(
        email: email,
        password: password,
      );

      // Check role permissions
      if (!profile.hasAdminAccess) {
        emit(const AuthError('Access denied. Only Admin and Staff accounts are permitted here.'));
        await _authRepository.signOut();
        return;
      }

      emit(Authenticated(profile));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Sign out
  Future<void> logout() async {
    emit(const AuthLoading(message: 'Signing out...'));
    try {
      await _authRepository.signOut();
      emit(const Unauthenticated());
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  /// Helper getters
  bool get isAuthenticated => state is Authenticated;
  bool get isAdmin => state is Authenticated && (state as Authenticated).isAdmin;
  bool get isStaff => state is Authenticated && (state as Authenticated).isStaff;
  ProfileModel? get currentProfile =>
      state is Authenticated ? (state as Authenticated).profile : null;

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
