import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../services/api/api_auth_service.dart';

class AuthRepository {
  final ApiAuthService _authService = ApiAuthService();

  Future<AuthUser?> login({
    required String email,
    required String password,
  }) {
    return _authService.login(email: email, password: password);
  }

  Future<AuthUser?> register({
    required String email,
    required String password,
    String? name,
  }) {
    return _authService.register(email: email, password: password, name: name);
  }

  Future<AuthUser?> getCurrentUser() {
    return _authService.getCurrentUser();
  }

  Future<AuthUser?> refreshToken() {
    return _authService.refreshToken();
  }

  Future<void> logout() {
    return _authService.logout();
  }

  Future<void> forgotPassword({required String email}) {
    return _authService.forgotPassword(email: email);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
