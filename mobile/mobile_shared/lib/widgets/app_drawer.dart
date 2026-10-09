import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

enum AppDrawerRole {
  admin,
  staff,
}

class AppDrawerItem {
  final IconData icon;
  final String title;
  final String route;

  const AppDrawerItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}

class CineplexDrawer extends StatelessWidget {
  final AppDrawerRole role;

  const CineplexDrawer({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user : null;
    });

    final isAdmin = role == AppDrawerRole.admin;
    final roleBadge = isAdmin ? l10n.adminBadge : l10n.staffBadge;
    final roleFallback = isAdmin ? l10n.adminRole : l10n.staffRole;
    final avatarLetter =
        (user?.fullName != null && user!.fullName.trim().isNotEmpty)
            ? user.fullName.trim()[0].toUpperCase()
            : (isAdmin ? 'A' : 'S');

    // Common items shared between Staff and Admin in the exact same order
    final commonManagementItems = [
      AppDrawerItem(
        icon: LucideIcons.ticket,
        title: l10n.ticketManagement,
        route: '/ticket-management',
      ),
      AppDrawerItem(
        icon: LucideIcons.film,
        title: l10n.manageMovies,
        route: '/movies',
      ),
      AppDrawerItem(
        icon: LucideIcons.calendarDays,
        title: l10n.manageShowtimes,
        route: '/showtimes',
      ),
      AppDrawerItem(
        icon: LucideIcons.mapPin,
        title: l10n.manageCinemas,
        route: '/cinemas',
      ),
      AppDrawerItem(
        icon: LucideIcons.film,
        title: l10n.showtimesAndOccupancy,
        route: '/showtimes-occupancy',
      ),
      AppDrawerItem(
        icon: LucideIcons.tag,
        title: l10n.managePromotions,
        route: '/promotions',
      ),
      AppDrawerItem(
        icon: LucideIcons.coffee,
        title: l10n.manageConcessions,
        route: '/concessions',
      ),
      AppDrawerItem(
        icon: LucideIcons.settings,
        title: l10n.adminSettings,
        route: '/settings',
      ),
    ];

    final List<AppDrawerItem> navItems =
        isAdmin
            ? [
              // Admin keeps first 2 items: Revenue Statistics and User Management
              AppDrawerItem(
                icon: LucideIcons.barChart3,
                title: l10n.revenueStatistics,
                route: '/statistics',
              ),
              AppDrawerItem(
                icon: LucideIcons.users,
                title: l10n.userManagement,
                route: '/users',
              ),
              AppDrawerItem(
                icon: LucideIcons.calendarClock,
                title: l10n.shiftSchedule,
                route: '/staff-shifts',
              ),
              // The rest taken from Staff in exact same order (quét vé and bán vé tại quầy are omitted)
              ...commonManagementItems,
            ]
            : [
              // Staff top navigation items
              AppDrawerItem(
                icon: LucideIcons.shoppingBag,
                title: l10n.counterSale,
                route: '/pos',
              ),
              AppDrawerItem(
                icon: LucideIcons.scanLine,
                title: l10n.scanTicket,
                route: '/scanner',
              ),
              AppDrawerItem(
                icon: LucideIcons.calendarCheck,
                title: l10n.shiftMySchedule,
                route: '/my-schedule',
              ),
              ...commonManagementItems,
            ];

    return Drawer(
      backgroundColor: theme.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Clickable Header Navigating to Profile
            InkWell(
              onTap: () {
                context.pop();
                context.go('/profile');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  theme.spacingMd,
                  theme.spacingMd,
                  theme.spacingMd,
                  theme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: theme.surface,
                  border: Border(
                    bottom: BorderSide(color: theme.borderSubtle, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primary, theme.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: CircleAvatar(
                        backgroundColor: theme.surface,
                        child: Text(
                          avatarLetter,
                          style: TextStyle(
                            color: theme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: theme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user?.fullName ?? roleFallback,
                                  style: TextStyle(
                                    color: theme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  roleBadge,
                                  style: TextStyle(
                                    color: theme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: theme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            // Drawer Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final item in navItems)
                    _buildDrawerItem(
                      context,
                      icon: item.icon,
                      title: item.title,
                      route: item.route,
                      theme: theme,
                    ),
                ],
              ),
            ),

            // Theme Mode Toggle Switcher
            Divider(color: theme.borderSubtle, height: 1),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, currentMode) {
                final isDark = currentMode == ThemeMode.dark;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    isDark ? LucideIcons.moon : LucideIcons.sun,
                    color: isDark ? theme.accent : const Color(0xFFF59E0B),
                    size: 20,
                  ),
                  title: Text(
                    isDark ? l10n.themeModeDark : l10n.themeModeLight,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeTrackColor: theme.primary,
                    onChanged: (_) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  ),
                );
              },
            ),

            // Logout Tile
            Divider(color: theme.borderSubtle, height: 1),
            ListTile(
              dense: true,
              leading: Icon(LucideIcons.logOut, color: theme.error, size: 20),
              title: Text(
                l10n.logout,
                style: TextStyle(
                  color: theme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              onTap: () {
                context.pop(); // Close drawer
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 4),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required CineplexColors theme,
  }) {
    String currentRoute = '';
    try {
      currentRoute = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      currentRoute = '';
    }
    final isSelected =
        currentRoute.isNotEmpty &&
        (currentRoute == route ||
            (route != '/' &&
                route != '/dashboard' &&
                route != '/statistics' &&
                currentRoute.startsWith('$route/')) ||
            (route == '/pos' &&
                (currentRoute.startsWith('/pos') ||
                    currentRoute.startsWith('/ticket-sale'))) ||
            (route == '/statistics' && currentRoute.startsWith('/statistics')));

    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: isSelected ? theme.accent : theme.textSecondary,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? theme.accent : theme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13.5,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.accent.withValues(alpha: 0.1),
      onTap: () {
        context.pop(); // Close drawer
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }
}

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CineplexDrawer(role: AppDrawerRole.admin);
  }
}

class StaffDrawer extends StatelessWidget {
  const StaffDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CineplexDrawer(role: AppDrawerRole.staff);
  }
}
