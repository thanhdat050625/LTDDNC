import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ConcessionManagementScreen extends StatefulWidget {
  final Widget? drawer;
  const ConcessionManagementScreen({super.key, this.drawer});

  @override
  State<ConcessionManagementScreen> createState() => _ConcessionManagementScreenState();
}

class _ConcessionManagementScreenState extends State<ConcessionManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConcessionManagementCubit>().loadConcessions();
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
    
    return AppScaffold(
      title: AppLocalizations.of(context)!.manageConcessions,
      drawer: widget.drawer,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _reloadAfterPush(context.push('/concessions/new')),
        backgroundColor: theme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<ConcessionManagementCubit, ConcessionManagementState>(
        builder: (context, state) {
          if (state is ConcessionManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ConcessionManagementError) {
            return Center(child: Text(state.message, style: TextStyle(color: theme.error)));
          } else if (state is ConcessionManagementLoaded) {
            final concessions = state.concessions;
            final summary = state.summary;
            
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(theme.spacingLg),
                  child: Row(
                    children: [
                      _buildSummaryCard(context, AppLocalizations.of(context)!.totalProducts, '${summary['total']}', theme.primary, theme),
                      SizedBox(width: theme.spacingMd),
                      _buildSummaryCard(context, AppLocalizations.of(context)!.lowStock, '${summary['lowStock']}', Colors.orange, theme),
                      SizedBox(width: theme.spacingMd),
                      _buildSummaryCard(context, AppLocalizations.of(context)!.outOfStock, '${summary['outOfStock']}', theme.error, theme),
                    ],
                  ),
                ),
                Expanded(
                  child: concessions.isEmpty
                      ? Center(child: Text(AppLocalizations.of(context)!.noConcessions))
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: theme.spacingLg),
                          itemCount: concessions.length,
                          separatorBuilder: (_, __) => SizedBox(height: theme.spacingMd),
                          itemBuilder: (context, index) {
                            final c = concessions[index];
                            return ConcessionListItem(
                              concession: c,
                              onEdit: () => _reloadAfterPush(context.push('/concessions/${c.id}/edit', extra: c)),
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (dCtx) => AlertDialog(
                                    backgroundColor: theme.surface,
                                    title: Text(AppLocalizations.of(context)!.confirmDelete),
                                    content: Text(AppLocalizations.of(context)!.confirmDeleteProduct),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dCtx),
                                        child: Text(AppLocalizations.of(context)!.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dCtx);
                                          context.read<ConcessionManagementCubit>().deleteConcession(c.id);
                                        },
                                        child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: theme.error)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                SizedBox(height: theme.spacingLg),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, Color color, CineplexColors theme) {
    return Expanded(
      child: AppCard(
        padding: EdgeInsets.all(theme.spacingMd),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
