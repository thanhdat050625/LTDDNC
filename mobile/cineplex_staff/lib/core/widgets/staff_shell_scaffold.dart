import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class StaffShellScaffold extends StatelessWidget {
  final Widget child;

  const StaffShellScaffold({super.key, required this.child});

  static int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/scanner')) return 1;
    if (location.startsWith('/pos') || location.startsWith('/ticket-sale')) return 2;
    if (location.startsWith('/showtimes-occupancy')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateIndex(context);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: _StaffGlassBottomBar(
        currentIndex: currentIndex,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/scanner');
              break;
            case 2:
              context.go('/pos');
              break;
            case 3:
              context.go('/showtimes-occupancy');
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

class _StaffGlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const _StaffGlassBottomBar({
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final tabs = [
      {'icon': LucideIcons.layoutDashboard, 'label': l10n.staffDashboard},
      {'icon': LucideIcons.scanLine, 'label': l10n.scanTicket},
      {'icon': LucideIcons.shoppingBag, 'label': l10n.counterSale},
      {'icon': LucideIcons.film, 'label': l10n.showtimesAndOccupancy},
      {'icon': LucideIcons.userCheck, 'label': l10n.profile},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.88),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                            color: colorScheme.primary.withValues(alpha: 0.16),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
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
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.65);

                          return Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => onTabSelected(index),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    tabs[index]['icon'] as IconData,
                                    color: color,
                                    size: 21,
                                  ),
                                  const SizedBox(height: 3),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Text(
                                      tabs[index]['label'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
