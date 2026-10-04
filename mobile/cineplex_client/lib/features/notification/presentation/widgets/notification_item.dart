import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/notification_cubit.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final colors = CineplexColors.of(context);

    return Container(
      color: notification.isRead ? Colors.transparent : colors.primary.withValues(alpha: 0.08),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (notification.isRead ? colors.iconMuted : colors.primary).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.type == 'PROMOTION' ? Icons.local_offer : Icons.notifications,
            color: notification.isRead ? colors.iconMuted : colors.primary,
            size: 20,
          ),
        ),
        title: Text(
          notification.subject,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              notification.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              FormatUtils.formatDate(notification.createdAt),
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationCubit>().markAsRead(notification.id);
          }
        },
      ),
    );
  }
}
