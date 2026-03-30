import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../services/api/api_auth_service.dart';
import '../services/api/dio_client.dart';
import 'app_provider.dart';
import 'connectivity_provider.dart';

/// Manages authentication state (guest vs authenticated).
///
/// On init, attempts to restore an existing session via cookies.
/// Provides login, register, and logout methods.
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final connectivity = ref.read(connectivityProvider);
    if (connectivity.isConnected && connectivity.isInitialized) {
      await _tryRestoreSession();
    } else {
      // No server connection — go straight to guest mode
      state = AuthState.guest();
    }
  }

  /// Attempt to restore a previous session using stored cookies.
  /// Tries GET /api/auth/me first, then POST /api/auth/refresh on 401.
  Future<void> _tryRestoreSession() async {
    try {
      final user = await ApiAuthService().getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
        ref.read(wishlistProvider.notifier).syncWithServer();
      } else {
        state = AuthState.guest();
      }
    } on DioException {
      // Token may have expired — try refresh
      try {
        final user = await ApiAuthService().refreshToken();
        if (user != null) {
          state = AuthState.authenticated(user);
          ref.read(wishlistProvider.notifier).syncWithServer();
          return;
        }
      } catch (_) {
        // Refresh also failed — stay as guest
      }
      state = AuthState.guest();
    }
  }

  /// Log in with email and password.
  /// Returns `true` on success, `false` on failure (error stored in state).
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Signal loading by keeping status as unknown
    state = const AuthState();
    try {
      final user = await ApiAuthService().login(
        email: email,
        password: password,
      );
      if (user != null) {
        state = AuthState.authenticated(user);
        ref.read(wishlistProvider.notifier).syncWithServer();
        return true;
      }
      state = AuthState.error('Login failed. Please check your credentials.');
      return false;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String? ??
              'Login failed. Please try again.')
          : 'Login failed. Please try again.';
      state = AuthState.error(message);
      return false;
    }
  }

  /// Register a new user account.
  /// Returns `true` on success, `false` on failure (error stored in state).
  Future<bool> register({
    required String email,
    required String password,
    String? name,
  }) async {
    // Signal loading by keeping status as unknown
    state = const AuthState();
    try {
      final user = await ApiAuthService().register(
        email: email,
        password: password,
        name: name,
      );
      if (user != null) {
        state = AuthState.authenticated(user);
        ref.read(wishlistProvider.notifier).syncWithServer();
        return true;
      }
      state = AuthState.error('Registration failed. Please try again.');
      return false;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] as String? ??
              'Registration failed. Please try again.')
          : 'Registration failed. Please try again.';
      state = AuthState.error(message);
      return false;
    }
  }

  /// Log out the current user. Clears server session, cookies, and local auth state.
  Future<void> logout() async {
    try {
      await ApiAuthService().logout();
    } catch (_) {
      // Best-effort — clear local state regardless
    }
    await DioClient.clearCookies();
    ref.read(wishlistProvider.notifier).onLogout();
    state = AuthState.guest();
  }

  /// Clear any error message from the auth state.
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// Global provider for authentication state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
