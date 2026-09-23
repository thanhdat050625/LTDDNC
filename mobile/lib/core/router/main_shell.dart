import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';

import 'package:cineplex_mobile/features/notification/presentation/cubit/notification_cubit.dart';

/// Main shell with bottom navigation bar.
/// Wraps the 5 main tabs: Home, Movies, Tickets, Notifications, Profile.
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/movies')) return 1;
    if (location.startsWith('/my-tickets')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = _calculateIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/movies');
            case 2:
              context.go('/my-tickets');
            case 3:
              context.go('/notifications');
            case 4:
              context.go('/profile');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.movie_outlined),
            activeIcon: const Icon(Icons.movie),
            label: l10n.movies,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.confirmation_number_outlined),
            activeIcon: const Icon(Icons.confirmation_number),
            label: l10n.myTickets,
          ),
          BottomNavigationBarItem(
            icon: _NotificationBadgeIcon(),
            activeIcon: _NotificationBadgeIcon(active: true),
            label: l10n.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

class _NotificationBadgeIcon extends StatelessWidget {
  final bool active;
  const _NotificationBadgeIcon({this.active = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final count = state is NotificationLoaded ? state.unreadCount : 0;
        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: Icon(active ? Icons.notifications : Icons.notifications_outlined),
        );
      },
    );
  }
}
