import 'package:mobile_shared/mobile_shared.dart';

class ProfileRepository {
  final DioClient _dioClient;

  ProfileRepository(this._dioClient);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dioClient.get('/users/profile');
    final apiResponse = ApiResponse.fromJson(response.data, (j) => j);
    return apiResponse.data;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _dioClient.put('/users/profile', data: data);
  }

  Future<Map<String, dynamic>> getLoyaltyInfo() async {
    final response = await _dioClient.get('/users/loyalty-info');
    final apiResponse = ApiResponse.fromJson(response.data, (j) => j);
    return apiResponse.data;
  }

  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    await _dioClient.post('/auth/change-password', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }
}
