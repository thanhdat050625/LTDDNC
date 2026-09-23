import 'package:cineplex_mobile/core/api/dio_client.dart';
import 'package:cineplex_mobile/core/api/api_response.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final DioClient _dioClient;

  NotificationRepository(this._dioClient);

  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await _dioClient.get('/notifications', queryParameters: {'page': page, 'pageSize': 20});
    final apiResponse = ApiResponse.fromJson(response.data);
    return (apiResponse.data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dioClient.get('/notifications/unread-count');
    final apiResponse = ApiResponse.fromJson(response.data);
    return apiResponse.data['unreadCount'] ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _dioClient.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dioClient.patch('/notifications/read-all');
  }
}
