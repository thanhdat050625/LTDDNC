import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    final theme = Theme.of(context).extension<CineplexColors>()!;
    
    return AppScaffold(
      title: AppLocalizations.of(context)!.manageCinemas,
      drawer: widget.drawer,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _reloadAfterPush(context.push('/cinemas/new')),
        backgroundColor: theme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<CinemaManagementCubit, CinemaManagementState>(
        builder: (context, state) {
          if (state is CinemaManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CinemaManagementError) {
            return Center(child: Text(state.message, style: TextStyle(color: theme.error)));
          } else if (state is CinemaManagementLoaded) {
            final cinemas = state.cinemas;
            if (cinemas.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.noCinemas));
            }
            return ListView.separated(
              padding: EdgeInsets.all(theme.spacingLg),
              itemCount: cinemas.length,
              separatorBuilder: (_, __) => SizedBox(height: theme.spacingMd),
              itemBuilder: (context, index) {
                final c = cinemas[index];
                return CinemaListItem(
                  cinema: c,
                  onTap: () {
                    // Navigate to Rooms of this cinema
                    context.push('/cinemas/${c.id}/rooms', extra: c);
                  },
                  onEdit: () => _reloadAfterPush(context.push('/cinemas/${c.id}/edit', extra: c)),
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        backgroundColor: theme.surface,
                        title: Text(AppLocalizations.of(context)!.confirmDelete),
                        content: Text(AppLocalizations.of(context)!.confirmDeleteCinema),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dCtx);
                              context.read<CinemaManagementCubit>().deleteCinema(c.id);
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
