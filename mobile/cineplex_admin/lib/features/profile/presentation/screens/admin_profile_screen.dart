import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class AdminProfileScreen extends StatelessWidget {
  final Widget? drawer;
  const AdminProfileScreen({super.key, this.drawer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    final adminName = (user?.fullName.isNotEmpty == true) ? user!.fullName : l10n.adminRole;
    final adminEmail = user?.email ?? 'admin@cineplex.vn';

    return AppScaffold(
      title: l10n.adminProfile,
      drawer: drawer,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            // Admin Profile Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundColor: colors.surface,
                      child: Text(
                        adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                adminName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.adminBadge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          adminEmail,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colors.textSecondary,
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
            const SizedBox(height: 16),

            // Account & Role Information Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.shieldCheck, color: colors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.adminRole,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(colors, l10n.userIdLabel, user?.id.toString() ?? '1'),
                  Divider(height: 16, color: colors.divider),
                  _buildInfoRow(colors, l10n.roleLabel, user?.role ?? 'ADMIN'),
                  Divider(height: 16, color: colors.divider),
                  _buildInfoRow(colors, l10n.statusLabel, l10n.statusActive, valueColor: colors.success),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Theme Preferences Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: colors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.themeModeSetting,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, currentMode) {
                      return SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              icon: const Icon(Icons.dark_mode_outlined, size: 16),
                              label: Text(l10n.themeModeDark, style: const TextStyle(fontSize: 12)),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              icon: const Icon(Icons.light_mode_outlined, size: 16),
                              label: Text(l10n.themeModeLight, style: const TextStyle(fontSize: 12)),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              icon: const Icon(Icons.phone_android_outlined, size: 16),
                              label: Text(l10n.themeModeSystem, style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                          selected: {currentMode},
                          onSelectionChanged: (selected) {
                            if (selected.isNotEmpty) {
                              context.read<ThemeCubit>().setThemeMode(selected.first);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, l10n, colors),
              icon: Icon(LucideIcons.logOut, size: 18, color: colors.error),
              label: Text(
                l10n.logout,
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.error.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(CineplexColors colors, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? colors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n, CineplexColors colors) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          l10n.logout,
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.logoutConfirm,
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel, style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
