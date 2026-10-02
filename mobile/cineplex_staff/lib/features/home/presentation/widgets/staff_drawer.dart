import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class StaffDrawer extends StatelessWidget {
  const StaffDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final user = context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user : null;
    });

    return Drawer(
      backgroundColor: theme.surface,
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.primary),
            accountName: Text(user?.fullName ?? 'Nhân viên'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.accent,
              child: const Icon(
                LucideIcons.user,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.scanLine,
                  title: 'Quét vé',
                  route: '/scanner',
                  theme: theme,
                ),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.ticket,
                  title: 'Bán vé tại quầy',
                  route: '/ticket-sale',
                  theme: theme,
                ),
                Divider(color: theme.textSecondary.withValues(alpha: 0.1)),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.film,
                  title: 'Quản lý Phim',
                  route: '/movies',
                  theme: theme,
                ),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.mapPin,
                  title: AppLocalizations.of(context)!.manageCinemas,
                  route: '/cinemas',
                  theme: theme,
                ),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.calendarDays,
                  title: 'Quản lý Suất chiếu',
                  route: '/showtimes',
                  theme: theme,
                ),
              ],
            ),
          ),

          // Logout
          Divider(color: theme.textSecondary.withValues(alpha: 0.1)),
          ListTile(
            leading: Icon(LucideIcons.logOut, color: theme.error),
            title: Text('Đăng xuất', style: TextStyle(color: theme.error)),
            onTap: () {
              context.pop(); // Close drawer
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
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
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isSelected = currentRoute.startsWith(route);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.accent : theme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? theme.accent : theme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.accent.withValues(alpha: 0.1),
      onTap: () {
        context.pop(); // Close drawer
        if (!isSelected) {
          context.push(route);
        }
      },
    );
  }
}
