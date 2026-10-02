import 'package:dio/dio.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ProfileRepository {
  final DioClient _dioClient;

  ProfileRepository(this._dioClient);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dioClient.get('/users/profile');
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        return raw['data'] as Map<String, dynamic>;
      }
      return raw;
    }
    return {};
  }

  Future<void> updateProfile(Map<String, dynamic> data, {String? avatarPath}) async {
    if (avatarPath != null) {
      final formData = FormData.fromMap(data);
      formData.files.add(MapEntry(
        'avatar',
        await MultipartFile.fromFile(avatarPath),
      ));
      await _dioClient.put('/users/profile', data: formData);
    } else {
      await _dioClient.put('/users/profile', data: data);
    }
  }

  Future<Map<String, dynamic>> getLoyaltyInfo() async {
    final response = await _dioClient.get('/users/loyalty-info');
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        return raw['data'] as Map<String, dynamic>;
      }
      return raw;
    }
    return {};
  }

  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    await _dioClient.post('/auth/change-password', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }
}
