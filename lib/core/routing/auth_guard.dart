import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import 'app_routes.dart';

/// Guard utility for role-based route protection
class RoleGuard {
  RoleGuard._();

  /// Check if user has permission for the specified roles
  static bool hasRole(AuthState state, List<UserRole> allowedRoles) {
    if (state is Authenticated) {
      return allowedRoles.contains(state.profile.role);
    }
    return false;
  }

  /// Check if current state has admin privileges
  static bool isAdmin(AuthState state) {
    if (state is Authenticated) {
      return state.isAdmin;
    }
    return false;
  }

  /// Check if current state has staff or admin privileges
  static bool hasAdminAccess(AuthState state) {
    if (state is Authenticated) {
      return state.hasAdminAccess;
    }
    return false;
  }

  /// Route redirect logic for GoRouter
  static String? guardRedirect(BuildContext context, String currentPath, AuthCubit authCubit) {
    final state = authCubit.state;
    final isAdminRoute = currentPath.startsWith('/admin');
    final isLoginRoute = currentPath == AppRoutes.login;

    // While auth is still initializing, don't redirect anywhere
    if (state is AuthInitial || state is AuthLoading) {
      return null;
    }

    // /login is always accessible when not authenticated
    if (isLoginRoute) {
      // Only redirect away from login if already authenticated as admin
      if (state is Authenticated && state.hasAdminAccess) {
        return AppRoutes.adminDashboard;
      }
      return null;
    }

    // Protecting /admin routes
    if (isAdminRoute) {
      if (state is! Authenticated) {
        return AppRoutes.login;
      }
      if (!state.hasAdminAccess) {
        return AppRoutes.login;
      }
    }

    return null;
  }
}

/// AdminGuard alias
typedef AdminGuard = RoleGuard;
