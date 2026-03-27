import '../../models/auth_state.dart';

abstract class AuthService {
  Future<AuthUser?> login({required String email, required String password});
  Future<AuthUser?> register({required String email, required String password, String? name});
  Future<AuthUser?> getCurrentUser();
  Future<AuthUser?> refreshToken();
  Future<void> logout();
  Future<void> forgotPassword({required String email});
  Future<void> changePassword({required String currentPassword, required String newPassword});
}
