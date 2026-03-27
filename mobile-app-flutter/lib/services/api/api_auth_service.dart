import 'package:dio/dio.dart';
import '../../models/auth_state.dart';
import '../interfaces/auth_service.dart';
import 'dio_client.dart';

class ApiAuthService implements AuthService {
  @override
  Future<AuthUser?> login(
      {required String email, required String password}) async {
    try {
      final response = await DioClient.instance.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response.data?['user'] != null) {
        return AuthUser.fromJson(
            response.data['user'] as Map<String, dynamic>);
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AuthUser?> register(
      {required String email, required String password, String? name}) async {
    try {
      final response =
          await DioClient.instance.post('/api/auth/register', data: {
        'email': email,
        'password': password,
        if (name != null && name.isNotEmpty) 'name': name,
      });
      if (response.data?['user'] != null) {
        return AuthUser.fromJson(
            response.data['user'] as Map<String, dynamic>);
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final response = await DioClient.instance.get('/api/auth/me');
      if (response.data?['user'] != null) {
        return AuthUser.fromJson(
            response.data['user'] as Map<String, dynamic>);
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AuthUser?> refreshToken() async {
    try {
      final response = await DioClient.instance.post('/api/auth/refresh');
      if (response.data?['user'] != null) {
        return AuthUser.fromJson(
            response.data['user'] as Map<String, dynamic>);
      }
      return null;
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await DioClient.instance.post('/api/auth/logout');
    } on DioException {
      // Ignore logout errors — clear local state regardless
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await DioClient.instance
        .post('/api/auth/forgot-password', data: {'email': email});
  }

  @override
  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    await DioClient.instance.post('/api/auth/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
