import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

import 'package:cineplex_staff/features/home/presentation/widgets/staff_drawer.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  bool _soundEnabled = true;
  bool _hapticEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CineplexColors.of(context);
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    final staffName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : l10n.staffRole;
    final staffEmail = user?.email ?? 'staff@cineplex.vn';
    const cinemaName = 'Cineplex Flagship';

    return AppScaffold(
      title: l10n.staffProfile,
      drawer: const StaffDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.primary.withValues(alpha: 0.15),
                    child: Text(
                      staffName.isNotEmpty ? staffName[0].toUpperCase() : 'S',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
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
                                staffName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.staffBadge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          staffEmail,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              size: 12,
                              color: theme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                cinemaName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Theme Settings Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: theme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.themeModeSetting,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
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
                              icon: const Icon(
                                Icons.dark_mode_outlined,
                                size: 16,
                              ),
                              label: Text(
                                l10n.themeModeDark,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              icon: const Icon(
                                Icons.light_mode_outlined,
                                size: 16,
                              ),
                              label: Text(
                                l10n.themeModeLight,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              icon: const Icon(
                                Icons.phone_android_outlined,
                                size: 16,
                              ),
                              label: Text(
                                l10n.themeModeSystem,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          selected: {currentMode},
                          onSelectionChanged: (selected) {
                            if (selected.isNotEmpty) {
                              context.read<ThemeCubit>().setThemeMode(
                                selected.first,
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scanner Preferences Card
            Material(
              color: theme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.scanLine,
                          color: theme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.soundAndHaptic,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.soundAndHapticDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.scanSoundTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.textPrimary,
                        ),
                      ),
                      value: _soundEnabled,
                      onChanged: (val) => setState(() => _soundEnabled = val),
                      activeThumbColor: theme.primary,
                    ),
                    Divider(height: 1, color: theme.borderSubtle),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.scanHapticTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.textPrimary,
                        ),
                      ),
                      value: _hapticEnabled,
                      onChanged: (val) => setState(() => _hapticEnabled = val),
                      activeThumbColor: theme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, l10n, theme),
              icon: Icon(LucideIcons.logOut, size: 18, color: theme.error),
              label: Text(
                l10n.endShift,
                style: TextStyle(
                  color: theme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.error.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 24,
                ),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App Version
            Text(
              'Cineplex Staff v1.0.0',
              style: TextStyle(fontSize: 12, color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(
    BuildContext context,
    AppLocalizations l10n,
    CineplexColors theme,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          l10n.endShift,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.logoutConfirm,
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
