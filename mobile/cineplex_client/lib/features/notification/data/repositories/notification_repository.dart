import 'package:mobile_shared/mobile_shared.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final DioClient _dioClient;

  NotificationRepository(this._dioClient);

  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await _dioClient.get('/notifications', queryParameters: {'page': page, 'pageSize': 20});
    final raw = response.data;
    final List<dynamic> list = (raw is Map && raw['data'] is List)
        ? raw['data'] as List<dynamic>
        : (raw is List ? raw : []);
    return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dioClient.get('/notifications/unread-count');
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final payload = raw['data'] ?? raw;
      if (payload is Map<String, dynamic>) return (payload['unreadCount'] as int?) ?? 0;
      if (payload is int) return payload;
    } else if (raw is int) {
      return raw;
    }
    return 0;
  }

  Future<void> markAsRead(String id) async {
    await _dioClient.patch('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dioClient.patch('/notifications/read-all');
  }
}
