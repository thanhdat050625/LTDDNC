import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/notification_model.dart';

class NotificationDetailBottomSheet extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailBottomSheet({super.key, required this.notification});

  static Future<void> show(BuildContext context, NotificationModel notification) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationDetailBottomSheet(notification: notification),
    );
  }

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

  String _getTypeLabel(String type, AppLocalizations l10n) {
    switch (type.toUpperCase()) {
      case 'TICKET_CONFIRM':
        return l10n.notificationTicketConfirm;
      case 'PROMOTION':
        return l10n.notificationPromotion;
      case 'SHOWTIME_REMINDER':
        return l10n.notificationReminder;
      case 'PAYMENT_FAILED':
        return l10n.notificationPaymentFailed;
      case 'ACCOUNT':
        return l10n.notificationAccount;
      case 'SYSTEM':
      default:
        return l10n.notificationSystem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final typeColor = _getTypeColor(notification.type, colors);
    final typeIcon = _getTypeIcon(notification.type);
    final typeLabel = _getTypeLabel(notification.type, l10n);
    final subjectLower = notification.subject.toLowerCase();
    final isLoginAlert = subjectLower.contains('đăng nhập') || subjectLower.contains('dang nhap');
    final hasLink = !isLoginAlert && notification.link != null && notification.link!.trim().isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header: Type badge & close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon, size: 16, color: typeColor),
                        const SizedBox(width: 6),
                        Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.iconSecondary, size: 20),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Subject
              Text(
                notification.subject,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // Timestamp
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: colors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    FormatUtils.formatDateTime(notification.createdAt),
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: colors.divider),
              const SizedBox(height: 16),

              // Scrollable content body
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    notification.content,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.55,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              if (hasLink) ...[
                AppButton(
                  text: (notification.type.toUpperCase() == 'TICKET_CONFIRM' ||
                          subjectLower.contains('vé') ||
                          subjectLower.contains('ve') ||
                          (notification.link?.contains('ticket') ?? false))
                      ? l10n.viewTickets
                      : l10n.notificationOpenLink,
                  backgroundColor: colors.primary,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final raw = notification.link?.trim() ?? '';
                    if (raw.isEmpty) return;

                    if (raw.startsWith('http://') || raw.startsWith('https://')) {
                      final uri = Uri.tryParse(raw);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                      return;
                    }

                    String route = raw;
                    if (subjectLower.contains('soát vé') || subjectLower.contains('soat ve')) {
                      if (route == '/profile' || route.isEmpty) {
                        route = '/my-tickets';
                      }
                    }
                    if (route == '/' || route.isEmpty) {
                      route = '/home';
                    } else if (route.startsWith('/booking-history/') ||
                        route.startsWith('/history/') ||
                        route.startsWith('/tickets/')) {
                      final id = route.split('/').last;
                      route = '/my-tickets/$id';
                    } else if (route == '/booking-history' ||
                        route == '/history' ||
                        route == '/tickets') {
                      route = '/my-tickets';
                    }

                    try {
                      context.push(route);
                    } catch (_) {
                      try {
                        context.go(route);
                      } catch (_) {}
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
              AppButton(
                text: l10n.close,
                isOutlined: true,
                textColor: colors.textPrimary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
