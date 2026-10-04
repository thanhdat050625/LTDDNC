import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/showtime/presentation/cubit/showtime_cubit.dart';
import 'package:cineplex_client/features/showtime/presentation/widgets/date_selector.dart';
import 'package:cineplex_client/features/showtime/presentation/widgets/showtime_card.dart';

class ShowtimeSelectionScreen extends StatefulWidget {
  final int movieId;

  const ShowtimeSelectionScreen({super.key, required this.movieId});

  @override
  State<ShowtimeSelectionScreen> createState() => _ShowtimeSelectionScreenState();
}

class _ShowtimeSelectionScreenState extends State<ShowtimeSelectionScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(14, (index) => today.add(Duration(days: index)));
    _selectedDate = _dates.first;
    context.read<ShowtimeCubit>().loadShowtimes(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectShowtime),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          DateSelector(
            dates: _dates,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<ShowtimeCubit>().loadShowtimes(widget.movieId),
              child: BlocBuilder<ShowtimeCubit, ShowtimeState>(
                builder: (context, state) {
                  if (state is ShowtimeLoading) {
                    return const Center(child: AppLoading());
                  } else if (state is ShowtimeError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        AppErrorView(
                          message: state.message,
                          onRetry: () => context.read<ShowtimeCubit>().loadShowtimes(widget.movieId),
                        ),
                      ],
                    );
                  } else if (state is ShowtimeLoaded) {
                    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
                    final showtimes = state.showtimes[dateKey] ?? [];

                    if (showtimes.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                          AppEmptyView(
                            icon: Icons.event_busy_outlined,
                            title: l10n.noShowtimes,
                          ),
                        ],
                      );
                    }

                    // Group by cinema
                    final Map<String, List<dynamic>> grouped = {};
                    final Map<String, String?> cinemaAddresses = {};
                    for (final st in showtimes) {
                      final cinemaName = st.room?.cinema?.name ?? l10n.unknownCinema;
                      if (!grouped.containsKey(cinemaName)) {
                        grouped[cinemaName] = [];
                        cinemaAddresses[cinemaName] = st.room?.cinema?.address;
                      }
                      grouped[cinemaName]!.add(st);
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final cinemaName = grouped.keys.elementAt(index);
                        final address = cinemaAddresses[cinemaName];
                        final cinemaShowtimes = grouped[cinemaName]!;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.textSecondary.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 20, color: colors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cinemaName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                        if (address != null && address.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            address,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: cinemaShowtimes.map((st) {
                                  return ShowtimeCard(
                                    showtime: st,
                                    onTap: () {
                                      context.push('/booking/${st.id}');
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
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

