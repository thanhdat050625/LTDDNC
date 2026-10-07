import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/repositories/statistics_repository.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();
  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}
class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final SummaryModel summary;
  final List<RevenuePeriodModel> revenuePeriods;
  final List<MoviePerformanceModel> movies;
  final String filterType; // 'year' | 'month' | 'custom'
  final int selectedYear;
  final int selectedMonth;
  final DateTime startDate;
  final DateTime endDate;
  final bool isUpdatingRevenue;

  const StatisticsLoaded({
    required this.summary,
    required this.revenuePeriods,
    required this.movies,
    this.filterType = 'year',
    required this.selectedYear,
    required this.selectedMonth,
    required this.startDate,
    required this.endDate,
    this.isUpdatingRevenue = false,
  });

  String get currentTimeFrame => filterType;
  num get totalFilteredRevenue => revenuePeriods.fold<num>(0, (sum, p) => sum + p.revenue);

  @override
  List<Object?> get props => [
        summary,
        revenuePeriods,
        movies,
        filterType,
        selectedYear,
        selectedMonth,
        startDate,
        endDate,
        isUpdatingRevenue,
      ];

  StatisticsLoaded copyWith({
    SummaryModel? summary,
    List<RevenuePeriodModel>? revenuePeriods,
    List<MoviePerformanceModel>? movies,
    String? filterType,
    int? selectedYear,
    int? selectedMonth,
    DateTime? startDate,
    DateTime? endDate,
    bool? isUpdatingRevenue,
  }) {
    return StatisticsLoaded(
      summary: summary ?? this.summary,
      revenuePeriods: revenuePeriods ?? this.revenuePeriods,
      movies: movies ?? this.movies,
      filterType: filterType ?? this.filterType,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isUpdatingRevenue: isUpdatingRevenue ?? this.isUpdatingRevenue,
    );
  }
}

class StatisticsError extends StatisticsState {
  final String message;
  const StatisticsError(this.message);
  @override
  List<Object?> get props => [message];
}

class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository repository;

  StatisticsCubit(this.repository) : super(StatisticsInitial());

  static String _formatDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> loadStats({
    String filterType = 'year',
    int? year,
    int? month,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(StatisticsLoading());
    try {
      final now = DateTime.now();
      final effectiveYear = year ?? now.year;
      final effectiveMonth = month ?? now.month;
      final effectiveStart = startDate ?? now.subtract(const Duration(days: 13));
      final effectiveEnd = endDate ?? now;

      final results = await Future.wait([
        repository.getSummary(),
        repository.getRevenueStatistics(
          filterType: filterType,
          year: effectiveYear,
          month: effectiveMonth,
          startDate: _formatDate(effectiveStart),
          endDate: _formatDate(effectiveEnd),
        ),
        repository.getMoviePerformance(),
      ]);

      emit(StatisticsLoaded(
        summary: results[0] as SummaryModel,
        revenuePeriods: results[1] as List<RevenuePeriodModel>,
        movies: results[2] as List<MoviePerformanceModel>,
        filterType: filterType,
        selectedYear: effectiveYear,
        selectedMonth: effectiveMonth,
        startDate: effectiveStart,
        endDate: effectiveEnd,
      ));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }

  Future<void> updateRevenueFilter({
    String? filterType,
    int? year,
    int? month,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final currentState = state;
    if (currentState is! StatisticsLoaded) {
      await loadStats(
        filterType: filterType ?? 'year',
        year: year,
        month: month,
        startDate: startDate,
        endDate: endDate,
      );
      return;
    }

    final newType = filterType ?? currentState.filterType;
    final newYear = year ?? currentState.selectedYear;
    final newMonth = month ?? currentState.selectedMonth;
    final newStart = startDate ?? currentState.startDate;
    final newEnd = endDate ?? currentState.endDate;

    emit(currentState.copyWith(
      isUpdatingRevenue: true,
      filterType: newType,
      selectedYear: newYear,
      selectedMonth: newMonth,
      startDate: newStart,
      endDate: newEnd,
    ));

    try {
      final revenue = await repository.getRevenueStatistics(
        filterType: newType,
        year: newYear,
        month: newMonth,
        startDate: _formatDate(newStart),
        endDate: _formatDate(newEnd),
      );

      emit(currentState.copyWith(
        revenuePeriods: revenue,
        filterType: newType,
        selectedYear: newYear,
        selectedMonth: newMonth,
        startDate: newStart,
        endDate: newEnd,
        isUpdatingRevenue: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isUpdatingRevenue: false));
    }
  }

  // Backward compatibility alias
  Future<void> updateTimeFrame(String timeFrame, {int? year, int? month}) async {
    await updateRevenueFilter(filterType: timeFrame, year: year, month: month);
  }
}
