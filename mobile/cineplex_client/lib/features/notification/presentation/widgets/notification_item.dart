import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/models/notification_model.dart';
import '../cubit/notification_cubit.dart';
import 'notification_detail_bottom_sheet.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({super.key, required this.notification});

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'TICKET_CONFIRM':
        return Icons.confirmation_number_outlined;
      case 'PROMOTION':
        return Icons.local_offer_outlined;
      case 'SHOWTIME_REMINDER':
        return Icons.alarm_outlined;
      case 'PAYMENT_FAILED':
        return Icons.error_outline_rounded;
      case 'ACCOUNT':
        return Icons.person_outline_rounded;
      case 'SYSTEM':
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(String type, CineplexColors colors) {
    switch (type.toUpperCase()) {
      case 'TICKET_CONFIRM':
        return colors.success;
      case 'PAYMENT_FAILED':
        return colors.error;
      case 'SHOWTIME_REMINDER':
        return colors.warning;
      case 'PROMOTION':
      case 'ACCOUNT':
      case 'SYSTEM':
      default:
        return colors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CineplexColors.of(context);
    final typeColor = notification.isRead
        ? colors.iconMuted
        : _getTypeColor(notification.type, colors);

    return Material(
      color: notification.isRead ? Colors.transparent : colors.primary.withValues(alpha: 0.08),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTypeIcon(notification.type),
            color: typeColor,
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
        trailing: Icon(
          Icons.chevron_right,
          size: 18,
          color: colors.textMuted,
        ),
        onTap: () {
          if (!notification.isRead) {
            try {
              context.read<NotificationCubit>().markAsRead(notification.id);
            } catch (_) {}
          }
          NotificationDetailBottomSheet.show(context, notification);
        },
      ),
    );
  }
}
