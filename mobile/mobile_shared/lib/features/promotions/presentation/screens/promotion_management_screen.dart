import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class PromotionManagementScreen extends StatefulWidget {
  final Widget? drawer;
  const PromotionManagementScreen({super.key, this.drawer});

  @override
  State<PromotionManagementScreen> createState() => _PromotionManagementScreenState();
}

class _PromotionManagementScreenState extends State<PromotionManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<PromotionManagementCubit>().loadPromotions();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reloadAfterPush(Future<Object?> future) async {
    await future;
    if (mounted) {
      context.read<PromotionManagementCubit>().loadPromotions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.managePromotions,
      drawer: widget.drawer,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.plus),
          tooltip: l10n.addPromotion,
          onPressed: () => _reloadAfterPush(context.push('/promotions/new')),
        ),
      ],
      body: Column(
        children: [
          // 4 Core Promotional KPI Cards
          BlocBuilder<PromotionManagementCubit, PromotionManagementState>(
            buildWhen: (prev, curr) => curr is PromotionManagementLoaded,
            builder: (context, state) {
              if (state is! PromotionManagementLoaded) {
                return const SizedBox.shrink();
              }
              return _buildKpiSection(context, state);
            },
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: AppTextField(
              controller: _searchController,
              hintText: l10n.promotionSearchPlaceholder,
              prefixIcon: LucideIcons.search,
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  context.read<PromotionManagementCubit>().searchPromotions(val);
                });
              },
            ),
          ),

          // Promotion List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<PromotionManagementCubit>().loadPromotions(),
              child: BlocBuilder<PromotionManagementCubit, PromotionManagementState>(
                builder: (context, state) {
                  if (state is PromotionManagementLoading) {
                    return const Center(child: AppLoading());
                  } else if (state is PromotionManagementError) {
                    return AppErrorView(
                      message: state.message,
                      onRetry: () => context.read<PromotionManagementCubit>().loadPromotions(),
                    );
                  } else if (state is PromotionManagementLoaded) {
                    final promotions = state.promotions;
                    if (promotions.isEmpty) {
                      final hasFilterOrSearch = state.selectedFilter != null || state.searchQuery.isNotEmpty;
                      return LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: AppEmptyView(
                              icon: LucideIcons.ticketPercent,
                              title: l10n.noPromotions,
                              message: hasFilterOrSearch ? l10n.noData : l10n.noPromotionsSubtitle,
                              actionLabel: hasFilterOrSearch ? null : l10n.addPromotion,
                              onAction: hasFilterOrSearch
                                  ? null
                                  : () => _reloadAfterPush(context.push('/promotions/new')),
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: promotions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final p = promotions[index];
                        return PromotionListItem(
                          promotion: p,
                          onEdit: () => _reloadAfterPush(context.push('/promotions/${p.id}/edit', extra: p)),
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                backgroundColor: theme.surface,
                                title: Text(l10n.confirmDelete),
                                content: Text(l10n.confirmDeletePromotion),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx),
                                    child: Text(l10n.cancel, style: TextStyle(color: theme.textSecondary)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dCtx);
                                      context.read<PromotionManagementCubit>().deletePromotion(p.id);
                                    },
                                    child: Text(l10n.delete, style: TextStyle(color: theme.error)),
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

  Widget _buildKpiSection(BuildContext context, PromotionManagementLoaded state) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    final all = state.allPromotions;
    final totalCount = all.length;
    final activeCount = all.where((p) => p.isActive && !p.endDate.isBefore(now)).length;
    final expiredCount = all.where((p) => p.endDate.isBefore(now)).length;
    final pausedCount = all.where((p) => !p.isActive).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
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
            title: l10n.promotionTotal,
            count: totalCount,
            icon: LucideIcons.ticketPercent,
            accentColor: theme.primary,
            isSelected: state.selectedFilter == null,
            onTap: () => context.read<PromotionManagementCubit>().filterByStatus(null),
          ),
          _buildKpiCard(
            context,
            title: l10n.promotionActive,
            count: activeCount,
            icon: LucideIcons.checkCircle2,
            accentColor: theme.success,
            isSelected: state.selectedFilter == 'ACTIVE',
            onTap: () => context.read<PromotionManagementCubit>().filterByStatus('ACTIVE'),
          ),
          _buildKpiCard(
            context,
            title: l10n.promotionExpired,
            count: expiredCount,
            icon: LucideIcons.clock,
            accentColor: theme.warning,
            isSelected: state.selectedFilter == 'EXPIRED',
            onTap: () => context.read<PromotionManagementCubit>().filterByStatus('EXPIRED'),
          ),
          _buildKpiCard(
            context,
            title: l10n.promotionPaused,
            count: pausedCount,
            icon: LucideIcons.pauseCircle,
            accentColor: theme.textMuted,
            isSelected: state.selectedFilter == 'PAUSED',
            onTap: () => context.read<PromotionManagementCubit>().filterByStatus('PAUSED'),
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
                  child: Icon(icon, size: 14, color: accentColor),
                ),
                const Spacer(),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? accentColor : theme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
