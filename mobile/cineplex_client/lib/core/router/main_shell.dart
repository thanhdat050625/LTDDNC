import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:cineplex_client/features/notification/presentation/cubit/notification_cubit.dart';

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
              height: 68,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.65),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / tabs.length;
                  return Stack(
                    children: [
                      // Active Tab Capsule Indicator
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        left: currentIndex * tabWidth,
                        top: 5,
                        bottom: 5,
                        width: tabWidth,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      // Tabs
                      Row(
                        children: List.generate(tabs.length, (index) {
                          final isSelected = index == currentIndex;
                          final color = isSelected 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTabSelected(index),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (index == 3) 
                                    _NotificationBadgeIcon(color: color, size: 22)
                                  else
                                    Icon(tabs[index]['icon'] as IconData, color: color, size: 22),
                                  const SizedBox(height: 3),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Text(
                                      tabs[index]['label'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        color: color,
                                      ),
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
  final double size;
  const _NotificationBadgeIcon({required this.color, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final count = state is NotificationLoaded ? state.unreadCount : 0;
        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: Icon(LucideIcons.bell, color: color, size: size),
        );
      },
    );
  }
}

