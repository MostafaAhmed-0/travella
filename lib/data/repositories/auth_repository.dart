import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../datasources/auth_remote_data_source.dart';
import '../models/profile_model.dart';
import '../services/supabase_service.dart';

abstract class AuthRepository {
  Future<ProfileModel> signIn({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<ProfileModel?> getCurrentProfile();

  sb.User? getCurrentUser();

  bool get isAuthenticated;

  Stream<sb.AuthState> get authStateChanges;
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? AuthRemoteDataSourceImpl();

  @override
  Future<ProfileModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.signInWithEmailPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('User authentication failed. No user found.');
      }

      // Fetch profile role from database
      final profile = await _dataSource.getProfile(user.id);
      if (profile != null) {
        return profile;
      }

      // Fallback if profile row is not yet created, synthesize a profile
      return ProfileModel(
        id: user.id,
        email: user.email ?? email,
        fullName: user.userMetadata?['full_name'] as String? ?? 'Travella User',
        role: (user.email?.toLowerCase().contains('admin') == true)
            ? UserRole.admin
            : UserRole.staff,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // If error occurs, rethrow with clean message
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _dataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  Future<ProfileModel?> getCurrentProfile() async {
    final user = _dataSource.getCurrentUser();
    if (user == null) return null;

    final profile = await _dataSource.getProfile(user.id);
    if (profile != null) return profile;

    // Default fallback from user metadata
    return ProfileModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String? ?? 'Admin',
      role: (user.email?.toLowerCase().contains('admin') == true)
          ? UserRole.admin
          : UserRole.staff,
      createdAt: DateTime.now(),
    );
  }

  @override
  sb.User? getCurrentUser() => _dataSource.getCurrentUser();

  @override
  bool get isAuthenticated => SupabaseService.isAuthenticated;

  @override
  Stream<sb.AuthState> get authStateChanges => _dataSource.authStateChanges;
}
