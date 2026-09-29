import 'package:cineplex_mobile/core/api/dio_client.dart';
import 'package:cineplex_mobile/core/api/api_response.dart';

class UserManagementRepository {
  final DioClient _dioClient;

  UserManagementRepository(this._dioClient);

  Future<List<Map<String, dynamic>>> getUsers({int page = 1, int pageSize = 50}) async {
    final response = await _dioClient.get('/users', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    final apiResponse = ApiResponse.fromJson(response.data);
    return (apiResponse.data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> searchUsers(String keyword) async {
    final response = await _dioClient.get('/users/search', queryParameters: {
      'keyword': keyword,
    });
    final apiResponse = ApiResponse.fromJson(response.data);
    return (apiResponse.data as List).cast<Map<String, dynamic>>();
  }

  Future<void> updateUserStatus(int userId, String status) async {
    await _dioClient.put('/users/$userId/status', data: {
      'status': status,
    });
  }
}
