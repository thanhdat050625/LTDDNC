import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class AppSettingsScreen extends StatelessWidget {
  final Widget? drawer;
  final String? appName;

  const AppSettingsScreen({super.key, this.drawer, this.appName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);
    final displayedAppName = appName ?? '${l10n.appName} Admin';

    return AppScaffold(
      title: l10n.adminSettings,
      drawer: drawer,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode Section
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
                      Icon(
                        Icons.palette_outlined,
                        color: colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.themeModeSetting,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
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

            // System Information Section
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
                      Icon(LucideIcons.info, color: colors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.systemInfo,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSettingRow(colors, l10n.appName, displayedAppName),
                  Divider(height: 16, color: colors.divider),
                  _buildSettingRow(
                    colors,
                    l10n.appVersion,
                    'v1.0.0 (Production)',
                  ),
                  Divider(height: 16, color: colors.divider),
                  _buildSettingRow(
                    colors,
                    l10n.systemSummary,
                    'Production Gateway',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cache & Storage Section
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
                      Icon(
                        LucideIcons.database,
                        color: colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.clearCache,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      l10n.clearCache,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                    trailing: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.clearCacheSuccess),
                            backgroundColor: colors.success,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: Text(l10n.clearCache),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(CineplexColors colors, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
