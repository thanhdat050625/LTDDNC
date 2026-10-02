import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeManagementScreen extends StatefulWidget {
  final Widget? drawer;
  const ShowtimeManagementScreen({super.key, this.drawer});

  @override
  State<ShowtimeManagementScreen> createState() => _ShowtimeManagementScreenState();
}

class _ShowtimeManagementScreenState extends State<ShowtimeManagementScreen> {

  @override
  void initState() {
    super.initState();
    context.read<ShowtimeManagementCubit>().loadShowtimes();
  }

  Future<void> _reloadAfterPush(Future<Object?> future) async {
    await future;
    if (mounted) {
      context.read<ShowtimeManagementCubit>().loadShowtimes();
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      context.read<ShowtimeManagementCubit>().filterByDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;

    return AppScaffold(
      title: AppLocalizations.of(context)!.manageShowtimes,
      drawer: widget.drawer,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _reloadAfterPush(context.push('/showtimes/new'));
        },
        backgroundColor: theme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            color: theme.surface,
            child: BlocBuilder<ShowtimeManagementCubit, ShowtimeManagementState>(
              builder: (context, state) {
                DateTime? selectedDate;
                if (state is ShowtimeManagementLoaded) {
                  selectedDate = state.selectedDate;
                }
                
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, selectedDate),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: theme.spacingMd, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.background,
                            borderRadius: BorderRadius.circular(theme.radiusMd),
                            border: Border.all(color: theme.textSecondary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.calendar, size: 20, color: theme.textSecondary),
                              SizedBox(width: theme.spacingMd),
                              Text(
                                selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : 'Lọc theo ngày',
                                style: TextStyle(color: selectedDate != null ? theme.textPrimary : theme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (selectedDate != null) ...[
                      SizedBox(width: theme.spacingSm),
                      IconButton(
                        icon: Icon(LucideIcons.x, color: theme.error),
                        onPressed: () {
                          context.read<ShowtimeManagementCubit>().filterByDate(null);
                        },
                      ),
                    ]
                  ],
                );
              },
            ),
          ),
          
          // Showtime List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<ShowtimeManagementCubit>().loadShowtimes(),
              child: BlocBuilder<ShowtimeManagementCubit, ShowtimeManagementState>(
                builder: (context, state) {
                  if (state is ShowtimeManagementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ShowtimeManagementError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(
                          child: Text(
                            state.message,
                            style: TextStyle(color: theme.error),
                          ),
                        ),
                      ],
                    );
                  } else if (state is ShowtimeManagementLoaded) {
                    final showtimes = state.showtimes;
                    if (showtimes.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          Center(child: Text(AppLocalizations.of(context)!.noShowtimesFound)),
                        ],
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: showtimes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final st = showtimes[index];
                        return ShowtimeListItem(
                          showtime: st,
                          onTap: () {
                            // View details
                          },
                          onEdit: () {
                            _reloadAfterPush(
                              context.push('/showtimes/${st.id}/edit', extra: st),
                            );
                          },
                          onDelete: () {
                            // Handle delete logic via Cubit
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: Text(AppLocalizations.of(context)!.confirmDelete),
                                content: Text(AppLocalizations.of(context)!.confirmDeleteShowtimeDesc),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx),
                                    child: Text(AppLocalizations.of(context)!.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dCtx);
                                      // Use ShowtimeFormCubit from another BlocProvider or add delete to ManagementCubit.
                                      // Let's add delete to ManagementCubit for list items.
                                      context.read<ShowtimeManagementCubit>().deleteShowtime(st.id);
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
            ),
          ),
        ],
      ),
    );
  }
}
