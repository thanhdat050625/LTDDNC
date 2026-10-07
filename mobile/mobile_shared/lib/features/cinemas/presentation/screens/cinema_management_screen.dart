import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class CinemaManagementScreen extends StatefulWidget {
  final Widget? drawer;
  const CinemaManagementScreen({super.key, this.drawer});

  @override
  State<CinemaManagementScreen> createState() => _CinemaManagementScreenState();
}

class _CinemaManagementScreenState extends State<CinemaManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CinemaManagementCubit>().loadCinemas();
  }

  Future<void> _reloadAfterPush(Future<Object?> future) async {
    await future;
    if (mounted) {
      context.read<CinemaManagementCubit>().loadCinemas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return AppScaffold(
      title: l10n.manageCinemas,
      drawer: widget.drawer,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.plus),
          tooltip: l10n.addCinema,
          onPressed: () => _reloadAfterPush(context.push('/cinemas/new')),
        ),
      ],
      body: Column(
        children: [
          // 4 Core Operational KPI Cards
          BlocBuilder<CinemaManagementCubit, CinemaManagementState>(
            buildWhen: (prev, curr) => curr is CinemaManagementLoaded,
            builder: (context, state) {
              if (state is! CinemaManagementLoaded) {
                return const SizedBox.shrink();
              }
              return _buildKpiSection(context, state);
            },
          ),

          // Cinema List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<CinemaManagementCubit>().loadCinemas(),
              child: BlocBuilder<CinemaManagementCubit, CinemaManagementState>(
                builder: (context, state) {
                  if (state is CinemaManagementLoading) {
                    return const Center(child: AppLoading());
                  } else if (state is CinemaManagementError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: AppErrorView(
                          message: state.message,
                          onRetry: () => context.read<CinemaManagementCubit>().loadCinemas(),
                        ),
                      ),
                    );
                  } else if (state is CinemaManagementLoaded) {
                    final cinemas = state.cinemas;
                    if (cinemas.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: AppEmptyView(
                            icon: LucideIcons.building,
                            title: l10n.noCinemas,
                            actionLabel: l10n.addCinema,
                            onAction: () => _reloadAfterPush(context.push('/cinemas/new')),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: cinemas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final c = cinemas[index];
                        return CinemaListItem(
                          cinema: c,
                          onTap: () {
                            context.push('/cinemas/${c.id}/rooms', extra: c);
                          },
                          onEdit: () => _reloadAfterPush(
                            context.push('/cinemas/${c.id}/edit', extra: c),
                          ),
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                backgroundColor: theme.surface,
                                title: Text(l10n.confirmDelete),
                                content: Text(l10n.confirmDeleteCinema),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx),
                                    child: Text(
                                      l10n.cancel,
                                      style: TextStyle(color: theme.textSecondary),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(dCtx);
                                      context.read<CinemaManagementCubit>().deleteCinema(c.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.error,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(l10n.delete),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context, CinemaManagementLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CineplexColors.of(context);
    final all = state.allCinemas;
    final totalCount = all.length;
    final activeCount = all.where((c) => c.status.toUpperCase() == 'ACTIVE').length;
    final maintenanceCount = all.where((c) => c.status.toUpperCase() == 'MAINTENANCE').length;
    final inactiveCount = all.where((c) => c.status.toUpperCase() == 'INACTIVE').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.3,
        children: [
          _buildKpiCard(
            context,
            title: l10n.totalCinemas,
            count: totalCount,
            icon: LucideIcons.building,
            accentColor: theme.primary,
            isSelected: state.selectedStatus == null,
            onTap: () => context.read<CinemaManagementCubit>().filterByStatus(null),
          ),
          _buildKpiCard(
            context,
            title: l10n.cinemaStatusActive,
            count: activeCount,
            icon: LucideIcons.checkCircle,
            accentColor: theme.success,
            isSelected: state.selectedStatus == 'ACTIVE',
            onTap: () => context.read<CinemaManagementCubit>().filterByStatus('ACTIVE'),
          ),
          _buildKpiCard(
            context,
            title: l10n.cinemaStatusMaintenance,
            count: maintenanceCount,
            icon: LucideIcons.wrench,
            accentColor: theme.warning,
            isSelected: state.selectedStatus == 'MAINTENANCE',
            onTap: () => context.read<CinemaManagementCubit>().filterByStatus('MAINTENANCE'),
          ),
          _buildKpiCard(
            context,
            title: l10n.cinemaStatusInactive,
            count: inactiveCount,
            icon: LucideIcons.pauseCircle,
            accentColor: theme.textMuted,
            isSelected: state.selectedStatus == 'INACTIVE',
            onTap: () => context.read<CinemaManagementCubit>().filterByStatus('INACTIVE'),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = CineplexColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : theme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : theme.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: accentColor, size: 14),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? accentColor : theme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              maxLines: 1,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
