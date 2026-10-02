import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/statistics_cubit.dart';

class StatisticsScreen extends StatefulWidget {
  final Widget? drawer;
  const StatisticsScreen({super.key, this.drawer});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _sortByOccupancy = false;

  @override
  void initState() {
    super.initState();
    context.read<StatisticsCubit>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: l10n.statistics,
      drawer: widget.drawer,
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) return const AppLoading();
          if (state is StatisticsLoaded) {
            final summary = state.summary;
            final movies = List<MoviePerformanceModel>.from(state.movies);

            if (_sortByOccupancy) {
              movies.sort((a, b) => b.occupancyRate.compareTo(a.occupancyRate));
            } else {
              movies.sort((a, b) => b.revenue.compareTo(a.revenue));
            }

            return RefreshIndicator(
              onRefresh: () => context.read<StatisticsCubit>().loadStats(
                    timeFrame: state.currentTimeFrame,
                    year: state.selectedYear,
                    month: state.selectedMonth,
                  ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // KPI Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildKpiCard(
                        title: l10n.totalRevenue,
                        value: FormatUtils.formatCurrency(summary.revenue.toInt()),
                        icon: Icons.monetization_on_outlined,
                        containerColor: colorScheme.primaryContainer,
                        iconColor: colorScheme.primary,
                      ),
                      _buildKpiCard(
                        title: l10n.ticketsSold,
                        value: summary.tickets.toString(),
                        icon: Icons.confirmation_number_outlined,
                        containerColor: colorScheme.secondaryContainer,
                        iconColor: colorScheme.secondary,
                      ),
                      _buildKpiCard(
                        title: l10n.totalCinemas,
                        value: summary.cinemas.toString(),
                        icon: Icons.business_outlined,
                        containerColor: colorScheme.tertiaryContainer,
                        iconColor: colorScheme.tertiary,
                      ),
                      _buildKpiCard(
                        title: l10n.activeMovies,
                        value: summary.activeMovies.toString(),
                        icon: Icons.movie_outlined,
                        containerColor: colorScheme.surfaceContainerHighest,
                        iconColor: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Revenue Chart Section
                  _buildRevenueChartSection(context, state, l10n, colorScheme),
                  const SizedBox(height: 24),

                  // Movie Performance Section
                  _buildMoviePerformanceSection(context, movies, l10n, colorScheme),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          if (state is StatisticsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<StatisticsCubit>().loadStats(),
                    child: Text(l10n.retry),
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color containerColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChartSection(
    BuildContext context,
    StatisticsLoaded state,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final currentYear = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.revenueTrend,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // Timeframe dropdown
                  DropdownButton<String>(
                    value: state.currentTimeFrame,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 'month', child: Text(l10n.month)),
                      DropdownMenuItem(value: 'year', child: Text(l10n.year)),
                      DropdownMenuItem(value: 'week', child: Text(l10n.week)),
                      DropdownMenuItem(value: 'day', child: Text(l10n.day)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        context.read<StatisticsCubit>().updateTimeFrame(
                              val,
                              year: state.selectedYear,
                              month: state.selectedMonth,
                            );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  // Year dropdown
                  DropdownButton<int>(
                    value: state.selectedYear ?? currentYear,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (int y = currentYear; y >= currentYear - 3; y--)
                        DropdownMenuItem(value: y, child: Text(y.toString())),
                    ],
                    onChanged: (y) {
                      if (y != null) {
                        context.read<StatisticsCubit>().updateTimeFrame(
                              state.currentTimeFrame,
                              year: y,
                              month: state.selectedMonth,
                            );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Bar Chart
          if (state.revenuePeriods.isEmpty) ...[
            Container(
              height: 160,
              alignment: Alignment.center,
              child: Text(
                l10n.noRevenueInPeriod,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ] else ...[
            SizedBox(
              height: 180,
              child: _buildBarChart(state.revenuePeriods, colorScheme),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarChart(List<RevenuePeriodModel> periods, ColorScheme colorScheme) {
    final maxRevenue = periods.map((p) => p.revenue).reduce(math.max);
    final safeMax = maxRevenue > 0 ? maxRevenue : 1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: periods.map((p) {
          final ratio = (p.revenue / safeMax).clamp(0.05, 1.0);
          final barHeight = 120.0 * ratio;
          final shortPeriod = p.period.contains('-') ? p.period.split('-').last : p.period;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  p.revenue >= 1000000
                      ? '${(p.revenue / 1000000).toStringAsFixed(1)}M'
                      : (p.revenue >= 1000 ? '${(p.revenue / 1000).toStringAsFixed(0)}K' : p.revenue.toString()),
                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 28,
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  shortPeriod,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMoviePerformanceSection(
    BuildContext context,
    List<MoviePerformanceModel> movies,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.moviePerformance,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  setState(() => _sortByOccupancy = !_sortByOccupancy);
                },
                icon: const Icon(Icons.sort, size: 16),
                label: Text(
                  _sortByOccupancy ? l10n.occupancyRate : l10n.revenueCol,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (movies.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  l10n.noData,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ] else ...[
            ...movies.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (m.poster != null && m.poster!.trim().isNotEmpty)
                          ? AppCachedImage(
                              imageUrl: m.poster!.trim(),
                              width: 40,
                              height: 54,
                              borderRadius: 8,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 40,
                              height: 54,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.movie_outlined,
                                size: 22,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${FormatUtils.formatCurrency(m.revenue.toInt())} • ${m.ticketsSold} ${l10n.ticketsSoldCol}',
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: m.occupancyRate >= 50
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${m.occupancyRate}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: m.occupancyRate >= 50
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
