import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ConcessionManagementScreen extends StatefulWidget {
  final Widget? drawer;
  const ConcessionManagementScreen({super.key, this.drawer});

  @override
  State<ConcessionManagementScreen> createState() => _ConcessionManagementScreenState();
}

class _ConcessionManagementScreenState extends State<ConcessionManagementScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ConcessionManagementCubit>().loadConcessions();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reloadAfterPush(Future<Object?> future) async {
    await future;
    if (mounted) {
      context.read<ConcessionManagementCubit>().loadConcessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.manageConcessions,
      drawer: widget.drawer,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _reloadAfterPush(context.push('/concessions/new')),
        backgroundColor: theme.accent,
        tooltip: l10n.addProduct,
        elevation: theme.elevationSm,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: BlocBuilder<ConcessionManagementCubit, ConcessionManagementState>(
        builder: (context, state) {
          if (state is ConcessionManagementLoading) {
            return const Center(child: AppLoading());
          } else if (state is ConcessionManagementError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.alertCircle, size: 48, color: theme.error),
                  SizedBox(height: theme.spacingMd),
                  Text(state.message, style: TextStyle(color: theme.error)),
                  SizedBox(height: theme.spacingMd),
                  ElevatedButton(
                    onPressed: () => context.read<ConcessionManagementCubit>().loadConcessions(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          } else if (state is ConcessionManagementLoaded) {
            final summary = state.summary;
            final allConcessions = state.concessions;
            final concessions = _searchQuery.isEmpty
                ? allConcessions
                : allConcessions.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();

            return RefreshIndicator(
              onRefresh: () => context.read<ConcessionManagementCubit>().loadConcessions(),
              color: theme.accent,
              backgroundColor: theme.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Metrics Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Row(
                        children: [
                          _buildSummaryCard(
                            context,
                            title: l10n.totalProducts,
                            value: '${summary['total']}',
                            icon: LucideIcons.package2,
                            color: theme.primary,
                            theme: theme,
                          ),
                          const SizedBox(width: 6),
                          _buildSummaryCard(
                            context,
                            title: l10n.lowStock,
                            value: '${summary['lowStock']}',
                            icon: LucideIcons.alertTriangle,
                            color: Colors.orange,
                            theme: theme,
                          ),
                          const SizedBox(width: 6),
                          _buildSummaryCard(
                            context,
                            title: l10n.outOfStock,
                            value: '${summary['outOfStock']}',
                            icon: LucideIcons.xCircle,
                            color: theme.error,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(theme.radiusMd),
                          border: Border.all(
                            color: theme.textSecondary.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          style: TextStyle(color: theme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: l10n.searchConcessionPlaceholder,
                            hintStyle: TextStyle(color: theme.textSecondary, fontSize: 13),
                            prefixIcon: Icon(LucideIcons.search, size: 16, color: theme.textSecondary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(LucideIcons.x, size: 14, color: theme.textSecondary),
                                    onPressed: () => _searchCtrl.clear(),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  )
                                : null,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Concession List or Empty State
                  if (concessions.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.accent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(LucideIcons.popcorn, size: 48, color: theme.accent),
                            ),
                            SizedBox(height: theme.spacingMd),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? l10n.noResultsFound
                                  : l10n.noConcessions,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: theme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final c = concessions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: ConcessionListItem(
                                concession: c,
                                onEdit: () => _reloadAfterPush(
                                  context.push('/concessions/${c.id}/edit', extra: c),
                                ),
                                onDelete: () => _showDeleteDialog(context, c, theme, l10n),
                              ),
                            );
                          },
                          childCount: concessions.length,
                        ),
                      ),
                    ),

                  // Bottom padding for FAB
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 72),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required CineplexColors theme,
  }) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 13, color: color),
                ),
                const SizedBox(width: 5),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ConcessionProductModel c, CineplexColors theme, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(l10n.confirmDelete, style: TextStyle(color: theme.textPrimary)),
        content: Text(l10n.confirmDeleteProduct, style: TextStyle(color: theme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(l10n.cancel, style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dCtx);
              context.read<ConcessionManagementCubit>().deleteConcession(c.id);
            },
            child: Text(l10n.delete, style: TextStyle(color: theme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
