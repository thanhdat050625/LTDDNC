import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Widget? drawer;
  const AdminDashboardScreen({super.key, this.drawer});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.adminDashboard,
      drawer: drawer,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: l10n.logout,
          onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final userName = state is AuthAuthenticated ? state.user.fullName : 'Admin';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.welcome}, $userName',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.adminPortal,
                      style: const TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Modules Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildModuleCard(
                  context: context,
                  title: l10n.userManagement,
                  subtitle: l10n.userManagementSubtitle,
                  icon: Icons.people_alt_rounded,
                  color: AppColors.secondary,
                  onTap: () => context.push('/users'),
                ),
                _buildModuleCard(
                  context: context,
                  title: l10n.statistics,
                  subtitle: l10n.statisticsSubtitle,
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.accent,
                  onTap: () => context.push('/statistics'),
                ),
                _buildModuleCard(
                  context: context,
                  title: l10n.counterSale,
                  subtitle: l10n.counterSaleDesc,
                  icon: Icons.point_of_sale_rounded, // Assuming Lucide is not imported here, fallback to material or use LucideIcons if imported. I'll use LucideIcons.monitorSmartphone if I import it. Let's just use LucideIcons.
                  color: AppColors.primary,
                  onTap: () => context.push('/ticket-sale'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
