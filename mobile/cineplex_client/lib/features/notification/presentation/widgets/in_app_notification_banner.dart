import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/models/notification_model.dart';

class InAppNotificationBanner {
  static OverlayEntry? _entry;
  static Timer? _dismissTimer;

  static void show({
    required BuildContext context,
    required NotificationModel notification,
    required VoidCallback onTap,
  }) {
    _dismissTimer?.cancel();
    _entry?.remove();
    _entry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _BannerWidget(
        notification: notification,
        onTap: () {
          _dismissTimer?.cancel();
          entry.remove();
          _entry = null;
          onTap();
        },
        onDismiss: () {
          _dismissTimer?.cancel();
          entry.remove();
          _entry = null;
        },
      ),
    );

    _entry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(const Duration(seconds: 4), () {
      if (_entry == entry) {
        entry.remove();
        _entry = null;
      }
    });
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _entry?.remove();
    _entry = null;
  }
}

class _BannerWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _BannerWidget({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = CineplexColors.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => onDismiss(),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadowColor,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: colors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            notification.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notification.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18, color: colors.textMuted),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: onDismiss,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
