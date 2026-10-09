import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../cubit/statistics_cubit.dart';

class StatisticsScreen extends StatefulWidget {
  final Widget? drawer;
  const StatisticsScreen({super.key, this.drawer});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsCubit>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: l10n.revenueStatistics,
      drawer: widget.drawer,
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) return const AppLoading();
          if (state is StatisticsLoaded) {
            final summary = state.summary;
            final movies = List<MoviePerformanceModel>.from(state.movies)
              ..sort((a, b) => b.revenue.compareTo(a.revenue));

            return RefreshIndicator(
              onRefresh: () => context.read<StatisticsCubit>().loadStats(
                    filterType: state.filterType,
                    year: state.selectedYear,
                    month: state.selectedMonth,
                    startDate: state.startDate,
                    endDate: state.endDate,
                  ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                children: [
                  // Filter Bar at the top
                  _buildFilterBar(context, state, l10n, colorScheme, colors),
                  const SizedBox(height: 8),

                  // KPI Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1.9,
                    children: [
                      _buildKpiCard(
                        context,
                        title: l10n.totalRevenue,
                        value: FormatUtils.formatCurrency(state.totalFilteredRevenue.toInt()),
                        icon: Icons.monetization_on_outlined,
                        accentColor: colors.accent,
                      ),
                      _buildKpiCard(
                        context,
                        title: l10n.ticketsSold,
                        value: state.totalFilteredTickets.toString(),
                        icon: Icons.confirmation_number_outlined,
                        accentColor: colors.primary,
                      ),
                      _buildKpiCard(
                        context,
                        title: l10n.totalCinemas,
                        value: summary.cinemas.toString(),
                        icon: Icons.business_outlined,
                        accentColor: colors.secondary,
                      ),
                      _buildKpiCard(
                        context,
                        title: l10n.activeMovies,
                        value: summary.activeMovies.toString(),
                        icon: Icons.movie_outlined,
                        accentColor: colors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Revenue Chart Section
                  _buildRevenueChartSection(context, state, l10n, colorScheme, colors),
                  const SizedBox(height: 8),

                  // Movie Performance Section
                  _buildMoviePerformanceSection(context, movies, l10n, colorScheme),
                  const SizedBox(height: 12),
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

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    final colors = CineplexColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor.withValues(alpha: 0.04),
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
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: accentColor, size: 15),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    StatisticsLoaded state,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    CineplexColors colors,
  ) {
    final currentYear = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Mode Tabs + updating spinner
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildFilterTab(
                        title: l10n.filterByYear,
                        isSelected: state.filterType == 'year',
                        onTap: () {
                          if (state.filterType != 'year') {
                            context.read<StatisticsCubit>().updateRevenueFilter(
                                  filterType: 'year',
                                  year: state.selectedYear,
                                );
                          }
                        },
                        colorScheme: colorScheme,
                      ),
                      _buildFilterTab(
                        title: l10n.filterByMonth,
                        isSelected: state.filterType == 'month',
                        onTap: () {
                          if (state.filterType != 'month') {
                            context.read<StatisticsCubit>().updateRevenueFilter(
                                  filterType: 'month',
                                  year: state.selectedYear,
                                  month: state.selectedMonth,
                                );
                          }
                        },
                        colorScheme: colorScheme,
                      ),
                      _buildFilterTab(
                        title: l10n.filterByDateRange,
                        isSelected: state.filterType == 'custom',
                        onTap: () {
                          if (state.filterType != 'custom') {
                            context.read<StatisticsCubit>().updateRevenueFilter(
                                  filterType: 'custom',
                                  startDate: state.startDate,
                                  endDate: state.endDate,
                                );
                          }
                        },
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
              ),
              if (state.isUpdatingRevenue) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Sub-filter selector based on active filter mode
          if (state.filterType == 'year')
            Row(
              children: [
                Icon(LucideIcons.calendar, size: 14, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  '${l10n.year}: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: DropdownButton<int>(
                    value: state.selectedYear,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (int y = currentYear; y >= currentYear - 4; y--)
                        DropdownMenuItem(value: y, child: Text(y.toString(), style: const TextStyle(fontSize: 12))),
                    ],
                    onChanged: (y) {
                      if (y != null) {
                        context.read<StatisticsCubit>().updateRevenueFilter(
                              filterType: 'year',
                              year: y,
                            );
                      }
                    },
                  ),
                ),
              ],
            )
          else if (state.filterType == 'month')
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.calendar, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.month}: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: DropdownButton<int>(
                        value: state.selectedMonth,
                        isDense: true,
                        underline: const SizedBox.shrink(),
                        items: [
                          for (int m = 1; m <= 12; m++)
                            DropdownMenuItem(
                              value: m,
                              child: Text(l10n.monthFormat(m), style: const TextStyle(fontSize: 12)),
                            ),
                        ],
                        onChanged: (m) {
                          if (m != null) {
                            context.read<StatisticsCubit>().updateRevenueFilter(
                                  filterType: 'month',
                                  year: state.selectedYear,
                                  month: m,
                                );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${l10n.year}: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: DropdownButton<int>(
                        value: state.selectedYear,
                        isDense: true,
                        underline: const SizedBox.shrink(),
                        items: [
                          for (int y = currentYear; y >= currentYear - 4; y--)
                            DropdownMenuItem(value: y, child: Text(y.toString(), style: const TextStyle(fontSize: 12))),
                        ],
                        onChanged: (y) {
                          if (y != null) {
                            context.read<StatisticsCubit>().updateRevenueFilter(
                                  filterType: 'month',
                                  year: y,
                                  month: state.selectedMonth,
                                );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            // Custom Date Range Button
            InkWell(
              onTap: () async {
                final cubit = context.read<StatisticsCubit>();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: DateTimeRange(start: state.startDate, end: state.endDate),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  cubit.updateRevenueFilter(
                    filterType: 'custom',
                    startDate: picked.start,
                    endDate: picked.end,
                  );
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.calendarRange, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${FormatUtils.formatDate(state.startDate)} - ${FormatUtils.formatDate(state.endDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.chevronDown, size: 12, color: colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChartSection(
    BuildContext context,
    StatisticsLoaded state,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    CineplexColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${l10n.totalRevenueLabel}: ${FormatUtils.formatCurrency(state.totalFilteredRevenue)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.chartRevenueUnit,
                style: TextStyle(
                  fontSize: 10,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Custom Bar Chart
          if (state.revenuePeriods.isEmpty) ...[
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Text(
                l10n.noRevenueInPeriod,
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
              ),
            ),
          ] else ...[
            AnimatedOpacity(
              opacity: state.isUpdatingRevenue ? 0.6 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                height: 135,
                child: _buildBarChart(state.revenuePeriods, colorScheme, state.filterType, l10n),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarChart(
    List<RevenuePeriodModel> periods,
    ColorScheme colorScheme,
    String filterType,
    AppLocalizations l10n,
  ) {
    final maxRevenue = periods.fold<num>(0, (prev, p) => p.revenue > prev ? p.revenue : prev);
    final safeMax = maxRevenue > 0 ? maxRevenue : 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final count = periods.length;
        final bool shouldExpand = count <= 16;

        Widget buildColumnItem(RevenuePeriodModel p, {double? fixedWidth}) {
          final hasRevenue = p.revenue > 0;
          final ratio = (p.revenue / safeMax).clamp(0.0, 1.0);
          final barHeight = hasRevenue ? (80.0 * ratio + 4.0) : 3.0;

          // Format label
          String label;
          if (filterType == 'year') {
            final m = int.tryParse(p.period.split('-').last) ?? 1;
            label = l10n.shortMonthFormat(m);
          } else if (filterType == 'month') {
            label = p.period.split('-').last;
          } else {
            final parts = p.period.split('-');
            if (parts.length >= 3) {
              label = '${parts[2]}/${parts[1]}';
            } else {
              label = p.period;
            }
          }

          final revenueText = hasRevenue
              ? (p.revenue >= 1000000
                  ? '${(p.revenue / 1000000).toStringAsFixed(1)}M'
                  : (p.revenue >= 1000 ? '${(p.revenue / 1000).toStringAsFixed(0)}K' : p.revenue.toString()))
              : '';

          final content = Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 12,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    revenueText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      color: hasRevenue ? colorScheme.primary : Colors.transparent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Tooltip(
                message: '${p.period}: ${FormatUtils.formatCurrency(p.revenue)}',
                child: Container(
                  width: shouldExpand ? 14.0 : 11.0,
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: hasRevenue
                        ? LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: hasRevenue ? null : colorScheme.outlineVariant.withValues(alpha: 0.25),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: hasRevenue ? colorScheme.onSurface : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: hasRevenue ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          );

          if (fixedWidth != null) {
            return SizedBox(width: fixedWidth, child: content);
          }
          return content;
        }

        if (shouldExpand) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: periods.map((p) => Expanded(child: buildColumnItem(p))).toList(),
          );
        }

        final itemWidth = (availableWidth / count).clamp(16.0, 32.0);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: periods.map((p) => buildColumnItem(p, fixedWidth: itemWidth)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMoviePerformanceSection(
    BuildContext context,
    List<MoviePerformanceModel> movies,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final colors = CineplexColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.moviePerformance,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          if (movies.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  l10n.noData,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ),
            ),
          ] else ...[
            ...movies.map((m) {
              final index = movies.indexOf(m);
              final isTop1 = index == 0;
              final isTop2 = index == 1;
              final isTop3 = index == 2;
              final rankBadgeColor = isTop1
                  ? const Color(0xFFF59E0B)
                  : (isTop2 ? const Color(0xFF94A3B8) : (isTop3 ? const Color(0xFFD97706) : colors.surfaceVariant));
              final rankTextColor = (isTop1 || isTop2 || isTop3) ? const Color(0xFF111827) : colors.textSecondary;

              final occupancyColor = m.occupancyRate >= 70
                  ? colors.success
                  : (m.occupancyRate >= 40 ? colors.accent : colors.secondary);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    // Rank Badge
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rankBadgeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: rankTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: (m.poster != null && m.poster!.trim().isNotEmpty)
                          ? AppCachedImage(
                              imageUrl: m.poster!.trim(),
                              width: 36,
                              height: 48,
                              borderRadius: 6,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 36,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colors.surfaceVariant,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.movie_outlined,
                                size: 20,
                                color: colors.textSecondary,
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${FormatUtils.formatCurrency(m.revenue.toInt())} • ${m.ticketsSold} ${l10n.ticketsSoldCol}',
                            style: TextStyle(fontSize: 11, color: colors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: (m.occupancyRate / 100).clamp(0.0, 1.0),
                              minHeight: 4,
                              backgroundColor: colors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
                            ),
                          ),
                        ],
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
