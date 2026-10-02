import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectShowtime),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          DateSelector(
            dates: _dates,
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 16),
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
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
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
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          Center(child: Text(l10n.noShowtimes)),
                        ],
                      );
                    }

                    // Group by cinema
                    final Map<String, List<dynamic>> grouped = {};
                    for (final st in showtimes) {
                      final cinemaName = st.room?.cinema?.name ?? 'Unknown Cinema';
                      if (!grouped.containsKey(cinemaName)) {
                        grouped[cinemaName] = [];
                      }
                      grouped[cinemaName]!.add(st);
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final cinemaName = grouped.keys.elementAt(index);
                        final cinemaShowtimes = grouped[cinemaName]!;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cinemaName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: cinemaShowtimes.map((st) {
                                  return ShowtimeCard(
                                    showtime: st,
                                    onTap: () {
                                      Navigator.pushNamed(context, '/seat-selection', arguments: st.id);
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
