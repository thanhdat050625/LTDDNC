import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import 'package:cineplex_mobile/core/utils/format_utils.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.isRead ? Colors.transparent : Colors.blue.withOpacity(0.1),
      child: ListTile(
        leading: Icon(
          notification.type == 'PROMOTION' ? Icons.local_offer : Icons.notifications,
          color: notification.isRead ? Colors.grey : Colors.blue,
        ),
        title: Text(
          notification.subject,
          style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.content, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(FormatUtils.formatDate(notification.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        onTap: () {
          // Mark as read logic
        },
      ),
    );
  }
}
