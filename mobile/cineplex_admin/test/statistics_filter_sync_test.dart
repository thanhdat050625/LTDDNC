import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_admin/features/statistics/data/repositories/statistics_repository.dart';
import 'package:cineplex_admin/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:cineplex_admin/features/statistics/presentation/screens/statistics_screen.dart';

class SyncTestStatisticsRepository implements StatisticsRepository {
  int getRevenueCallCount = 0;
  int getMovieCallCount = 0;
  String? lastFilterType;
  int? lastYear;
  int? lastMonth;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<SummaryModel> getSummary() async {
    return const SummaryModel(
      revenue: 500000000,
      tickets: 5000,
      cinemas: 10,
      activeMovies: 15,
    );
  }

  @override
  Future<List<RevenuePeriodModel>> getRevenueStatistics({
    String filterType = 'year',
    int? year,
    int? month,
    String? startDate,
    String? endDate,
  }) async {
    getRevenueCallCount++;
    lastFilterType = filterType;
    lastYear = year;
    lastMonth = month;

    if (filterType == 'month' && month == 5) {
      return const [
        RevenuePeriodModel(period: '2026-05-01', revenue: 12000000),
        RevenuePeriodModel(period: '2026-05-02', revenue: 18000000),
      ];
    }

    return const [
      RevenuePeriodModel(period: '2026-01', revenue: 20000000),
      RevenuePeriodModel(period: '2026-02', revenue: 30000000),
      RevenuePeriodModel(period: '2026-03', revenue: 25000000),
    ];
  }

  @override
  Future<List<MoviePerformanceModel>> getMoviePerformance({
    String filterType = 'year',
    int? year,
    int? month,
    String? startDate,
    String? endDate,
  }) async {
    getMovieCallCount++;
    if (filterType == 'month' && month == 5) {
      return const [
        MoviePerformanceModel(
          id: 9,
          title: 'Phim Tháng 5',
          ticketsSold: 450,
          revenue: 30000000,
          occupancyRate: 75,
        ),
      ];
    }

    return const [
      MoviePerformanceModel(
        id: 1,
        title: 'Phim Năm',
        ticketsSold: 1000,
        revenue: 75000000,
        occupancyRate: 80,
      ),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildWidget({required Widget child, required StatisticsCubit cubit}) {
    return BlocProvider<StatisticsCubit>.value(
      value: cubit,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: child,
      ),
    );
  }

  group('Admin Statistics Sync and Filter Tests', () {
    test('Cubit updateRevenueFilter synchronizes revenue periods and top movies', () async {
      final repo = SyncTestStatisticsRepository();
      final cubit = StatisticsCubit(repo);

      await cubit.loadStats(filterType: 'year', year: 2026);
      expect(repo.getRevenueCallCount, 1);
      expect(repo.getMovieCallCount, 1);

      final stateYear = cubit.state as StatisticsLoaded;
      expect(stateYear.totalFilteredRevenue, 75000000);
      expect(stateYear.totalFilteredTickets, 1000);
      expect(stateYear.movies.first.title, 'Phim Năm');

      // Now switch to Month filter (May 2026)
      await cubit.updateRevenueFilter(filterType: 'month', year: 2026, month: 5);
      expect(repo.getRevenueCallCount, 2);
      expect(repo.getMovieCallCount, 2);

      final stateMonth = cubit.state as StatisticsLoaded;
      expect(stateMonth.filterType, 'month');
      expect(stateMonth.selectedMonth, 5);
      // Period revenue: 12M + 18M = 30M
      expect(stateMonth.totalFilteredRevenue, 30000000);
      // Period tickets: 450
      expect(stateMonth.totalFilteredTickets, 450);
      expect(stateMonth.movies.first.title, 'Phim Tháng 5');
    });

    testWidgets('StatisticsScreen renders filter at the top and updates period totals on filter switch', (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = SyncTestStatisticsRepository();
      final cubit = StatisticsCubit(repo);

      await tester.pumpWidget(buildWidget(child: const StatisticsScreen(), cubit: cubit));
      await tester.pumpAndSettle();

      // Top filter tabs exist
      expect(find.text('Theo năm'), findsOneWidget);
      expect(find.text('Theo tháng'), findsOneWidget);
      expect(find.text('Khoảng ngày'), findsOneWidget);

      // Initially shows year total in KPI card
      expect(find.text(FormatUtils.formatCurrency(75000000)), findsWidgets);
      expect(find.text('Phim Năm'), findsOneWidget);

      // Tap "Theo tháng"
      await tester.tap(find.text('Theo tháng'));
      await tester.pumpAndSettle();

      // Now month sub-selector is visible and synced
      expect(repo.lastFilterType, 'month');
    });
  });
}
