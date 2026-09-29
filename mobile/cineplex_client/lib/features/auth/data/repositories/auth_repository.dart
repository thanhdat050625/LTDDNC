import 'package:cineplex_client/core/api/dio_client.dart';
import 'package:cineplex_client/features/auth/data/models/user_model.dart';
import 'package:cineplex_client/core/services/storage_service.dart';

class AuthRepository {
  final DioClient _dio;
  final StorageService _storage;

  AuthRepository(this._dio, this._storage);

  Future<UserModel> login(String email, String password, {bool rememberMe = false}) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    });
    final data = response.data['data'];
    final token = data['accessToken'] as String;
    await _storage.saveToken(token);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _storage.saveUserId(user.id);
    return user;
  }

  Future<void> sendOtp(String email, String purpose) async {
    await _dio.post('/auth/send-otp', data: {'email': email, 'purpose': purpose});
  }

  Future<UserModel> register(String email, String otp, String password, String confirmPassword) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'otp': otp,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    final data = response.data['data'];
    final token = data['accessToken'] as String;
    await _storage.saveToken(token);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _storage.saveUserId(user.id);
    return user;
  }

  Future<void> forgotPassword(String email, String otp, String newPassword, String confirmPassword) async {
    await _dio.post('/auth/forgot-password', data: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }

  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    await _dio.post('/auth/change-password', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await _storage.clearAll();
  }

  Future<UserModel?> checkAuth() async {
    final token = await _storage.getToken();
    if (token == null) return null;
    try {
      final response = await _dio.get('/users/profile');
      return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      await _storage.clearAll();
      return null;
    }
  }
}
