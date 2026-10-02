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
    final l10n = AppLocalizations.of(context)!;
    final user = context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated ? state.user : null;
    });

    final firstLetter = (user?.fullName != null && user!.fullName.trim().isNotEmpty)
        ? user.fullName.trim()[0].toUpperCase()
        : 'S';

    return Drawer(
      backgroundColor: theme.surface,
      child: Column(
        children: [
          // Sleek, Compact Horizontal Header
          SafeArea(
            bottom: false,
            child: Container(
              padding: EdgeInsets.fromLTRB(theme.spacingMd, theme.spacingMd, theme.spacingMd, theme.spacingSm),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.textSecondary.withValues(alpha: 0.1),
                    width: 1,
                  ),
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
                        firstLetter,
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
                                user?.fullName ?? l10n.staffRole,
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'STAFF',
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
                ],
              ),
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: theme.spacingSm),
              children: [
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.scanLine,
                  title: l10n.scanTicket,
                  route: '/scanner',
                  theme: theme,
                ),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.ticket,
                  title: l10n.ticketSaleAtCounter,
                  route: '/ticket-sale',
                  theme: theme,
                ),
                Divider(color: theme.textSecondary.withValues(alpha: 0.1)),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.film,
                  title: l10n.manageMovies,
                  route: '/movies',
                  theme: theme,
                ),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.mapPin,
                  title: l10n.manageCinemas,
                  route: '/cinemas',
                  theme: theme,
                ),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.calendarDays,
                  title: l10n.manageShowtimes,
                  route: '/showtimes',
                  theme: theme,
                ),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.tag,
                  title: l10n.managePromotions,
                  route: '/promotions',
                  theme: theme,
                ),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.coffee,
                  title: l10n.manageConcessions,
                  route: '/concessions',
                  theme: theme,
                ),
              ],
            ),
          ),

          // Logout
          Divider(color: theme.textSecondary.withValues(alpha: 0.1)),
          ListTile(
            leading: Icon(LucideIcons.logOut, color: theme.error),
            title: Text(l10n.logout, style: TextStyle(color: theme.error)),
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
