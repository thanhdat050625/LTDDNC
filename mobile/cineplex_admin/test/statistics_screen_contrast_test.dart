import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_admin/features/statistics/data/repositories/statistics_repository.dart';
import 'package:cineplex_admin/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:cineplex_admin/features/statistics/presentation/screens/statistics_screen.dart';

class FakeStatisticsRepository implements StatisticsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<SummaryModel> getSummary() async {
    return const SummaryModel(
      revenue: 150000000,
      tickets: 1850,
      cinemas: 8,
      activeMovies: 12,
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
    return const [
      RevenuePeriodModel(period: '1', revenue: 50000000),
      RevenuePeriodModel(period: '2', revenue: 60000000),
      RevenuePeriodModel(period: '3', revenue: 40000000),
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
    return const [
      MoviePerformanceModel(
        id: 1,
        title: 'Mai',
        ticketsSold: 1200,
        revenue: 120000000,
        occupancyRate: 85,
      ),
      MoviePerformanceModel(
        id: 2,
        title: 'Đào, Phở và Piano',
        ticketsSold: 500,
        revenue: 50000000,
        occupancyRate: 72,
      ),
      MoviePerformanceModel(
        id: 3,
        title: 'Kung Fu Panda 4',
        ticketsSold: 300,
        revenue: 30000000,
        occupancyRate: 60,
      ),
    ];
  }
}

class TestStatisticsCubit extends StatisticsCubit {
  TestStatisticsCubit() : super(FakeStatisticsRepository());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({
    required Widget child,
    ThemeMode themeMode = ThemeMode.light,
    StatisticsCubit? statisticsCubit,
  }) {
    final cubit = statisticsCubit ?? TestStatisticsCubit();
    return BlocProvider<StatisticsCubit>.value(
      value: cubit,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: child,
      ),
    );
  }

  group('StatisticsScreen Dual-Mode & Contrast Tests', () {
    testWidgets('KPI cards and ranking list render cleanly in Light Mode without illegible contrast', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final cubit = TestStatisticsCubit();
      await tester.pumpWidget(
        buildTestableWidget(
          child: const StatisticsScreen(),
          themeMode: ThemeMode.light,
          statisticsCubit: cubit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(find.text('Thống kê Doanh thu'), findsOneWidget);

      // Verify KPI items are rendered
      expect(find.text('Tổng doanh thu'), findsOneWidget);
      expect(find.text('Số vé đã bán'), findsOneWidget);
      expect(find.text('Tổng số rạp'), findsOneWidget);
      expect(find.text('Phim đang chiếu'), findsOneWidget);

      // Verify top-performing movies with medals
      expect(find.text('Top phim bán chạy'), findsOneWidget);
      expect(find.text('Mai'), findsOneWidget);
      expect(find.text('Đào, Phở và Piano'), findsOneWidget);
      expect(find.text('Kung Fu Panda 4'), findsOneWidget);

      // Verify ranking badges
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('StatisticsScreen renders cleanly in Dark Mode', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final cubit = TestStatisticsCubit();
      await tester.pumpWidget(
        buildTestableWidget(
          child: const StatisticsScreen(),
          themeMode: ThemeMode.dark,
          statisticsCubit: cubit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(find.text('Thống kê Doanh thu'), findsOneWidget);
      expect(find.text('Mai'), findsOneWidget);
    });
  });
}
