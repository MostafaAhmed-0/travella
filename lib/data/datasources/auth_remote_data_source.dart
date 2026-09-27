import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../services/supabase_service.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<ProfileModel?> getProfile(String userId);

  User? getCurrentUser();

  Session? getCurrentSession();

  Stream<AuthState> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  @override
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception(SupabaseService.handleError(e));
    }
  }

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await _client
          .from(SupabaseService.tableProfiles)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return ProfileModel.fromJson(data);
    } catch (e) {
      // If table doesn't exist yet or query fails, return null
      return null;
    }
  }

  @override
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  @override
  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
