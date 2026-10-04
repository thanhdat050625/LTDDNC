import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../widgets/date_carousel.dart';

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

  Future<void> _selectCustomDate(BuildContext context, DateTime? currentDate) async {
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
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.manageShowtimes,
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
          // Horizontal Date Carousel & Calendar Picker
          BlocBuilder<ShowtimeManagementCubit, ShowtimeManagementState>(
            builder: (context, state) {
              DateTime? selectedDate;
              if (state is ShowtimeManagementLoaded) {
                selectedDate = state.selectedDate;
              }

              return Row(
                children: [
                  Expanded(
                    child: DateCarousel(
                      selectedDate: selectedDate,
                      onDateSelected: (date) {
                        context.read<ShowtimeManagementCubit>().filterByDate(date);
                      },
                    ),
                  ),
                  Container(
                    height: 74,
                    color: theme.surface,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      icon: Icon(
                        LucideIcons.calendar,
                        size: 20,
                        color: selectedDate != null ? theme.accent : theme.textSecondary,
                      ),
                      tooltip: l10n.filterByDatePrompt,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      onPressed: () => _selectCustomDate(context, selectedDate),
                    ),
                  ),
                ],
              );
            },
          ),
          Divider(color: theme.borderSubtle, height: 1),

          // Showtime List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<ShowtimeManagementCubit>().loadShowtimes(),
              child: BlocBuilder<ShowtimeManagementCubit, ShowtimeManagementState>(
                builder: (context, state) {
                  if (state is ShowtimeManagementLoading) {
                    return const Center(child: AppLoading());
                  } else if (state is ShowtimeManagementError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: AppErrorView(
                          message: state.message,
                          onRetry: () => context.read<ShowtimeManagementCubit>().loadShowtimes(),
                        ),
                      ),
                    );
                  } else if (state is ShowtimeManagementLoaded) {
                    final showtimes = state.showtimes;
                    if (showtimes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: AppEmptyView(
                            icon: LucideIcons.calendarX,
                            title: l10n.noShowtimesFound,
                            message: l10n.noResultsFound,
                            actionLabel: l10n.addShowtime,
                            onAction: () => _reloadAfterPush(context.push('/showtimes/new')),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: showtimes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final st = showtimes[index];
                        return ShowtimeListItem(
                          showtime: st,
                          onTap: () {
                            _reloadAfterPush(
                              context.push('/showtimes/${st.id}/edit', extra: st),
                            );
                          },
                          onEdit: () {
                            _reloadAfterPush(
                              context.push('/showtimes/${st.id}/edit', extra: st),
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                backgroundColor: theme.surface,
                                title: Text(l10n.confirmDelete),
                                content: Text(l10n.confirmDeleteShowtimeDesc),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx),
                                    child: Text(l10n.cancel, style: TextStyle(color: theme.textSecondary)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(dCtx);
                                      context.read<ShowtimeManagementCubit>().deleteShowtime(st.id);
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
}
