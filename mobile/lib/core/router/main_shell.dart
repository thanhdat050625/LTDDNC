import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cineplex_mobile/l10n/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:cineplex_mobile/features/notification/presentation/cubit/notification_cubit.dart';

import 'dart:ui';

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
    final currentIndex = _calculateIndex(context);

    return Scaffold(
      extendBody: true, // Cho phép nội dung lướt xuống dưới thanh điều hướng
      body: child,
      bottomNavigationBar: _CustomGlassBottomBar(
        currentIndex: currentIndex,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/movies');
              break;
            case 2:
              context.go('/my-tickets');
              break;
            case 3:
              context.go('/notifications');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}

class _CustomGlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const _CustomGlassBottomBar({
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      {'icon': LucideIcons.house, 'label': l10n.home},
      {'icon': LucideIcons.film, 'label': l10n.movies},
      {'icon': LucideIcons.ticket, 'label': l10n.myTickets},
      {'icon': LucideIcons.bell, 'label': l10n.notifications},
      {'icon': LucideIcons.user, 'label': l10n.profile},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / tabs.length;
                  return Stack(
                    children: [
                      // Liquid Indicator
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        left: currentIndex * tabWidth,
                        top: 0,
                        bottom: 0,
                        width: tabWidth,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      // Tabs
                      Row(
                        children: List.generate(tabs.length, (index) {
                          final isSelected = index == currentIndex;
                          final color = isSelected 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTabSelected(index),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (index == 3) 
                                    _NotificationBadgeIcon(color: color)
                                  else
                                    Icon(tabs[index]['icon'] as IconData, color: color),
                                  const SizedBox(height: 2),
                                  Text(
                                    tabs[index]['label'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationBadgeIcon extends StatelessWidget {
  final Color color;
  const _NotificationBadgeIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final count = state is NotificationLoaded ? state.unreadCount : 0;
        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: Icon(LucideIcons.bell, color: color),
        );
      },
    );
  }
}

