import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_shared/mobile_shared.dart';

class PromotionManagementScreen extends StatefulWidget {
  final Widget? drawer;
  const PromotionManagementScreen({super.key, this.drawer});

  @override
  State<PromotionManagementScreen> createState() => _PromotionManagementScreenState();
}

class _PromotionManagementScreenState extends State<PromotionManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PromotionManagementCubit>().loadPromotions();
  }

  Future<void> _reloadAfterPush(Future<Object?> future) async {
    await future;
    if (mounted) {
      context.read<PromotionManagementCubit>().loadPromotions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;
    
    return AppScaffold(
      title: AppLocalizations.of(context)!.managePromotions,
      drawer: widget.drawer,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _reloadAfterPush(context.push('/promotions/new')),
        backgroundColor: theme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<PromotionManagementCubit, PromotionManagementState>(
        builder: (context, state) {
          if (state is PromotionManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PromotionManagementError) {
            return Center(child: Text(state.message, style: TextStyle(color: theme.error)));
          } else if (state is PromotionManagementLoaded) {
            final promotions = state.promotions;
            if (promotions.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.noPromotions));
            }
            return ListView.separated(
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
                        title: Text(AppLocalizations.of(context)!.confirmDelete),
                        content: Text(AppLocalizations.of(context)!.confirmDeletePromotion),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dCtx);
                              context.read<PromotionManagementCubit>().deletePromotion(p.id);
                            },
                            child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: theme.error)),
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
    );
  }
}
