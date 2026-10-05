import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../cubit/notification_cubit.dart';

class NotificationBadgeIcon extends StatelessWidget {
  final Color color;
  final double size;
  final IconData icon;

  const NotificationBadgeIcon({
    super.key,
    required this.color,
    this.size = 22,
    this.icon = LucideIcons.bell,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<NotificationCubit>();
    } catch (_) {
      return Icon(icon, color: color, size: size);
    }

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final count = state is NotificationLoaded ? state.unreadCount : 0;
        final badgeText = count > 99 ? '99+' : '$count';

        return Badge(
          isLabelVisible: count > 0,
          label: Text(
            badgeText,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(icon, color: color, size: size),
        );
      },
    );
  }
}
