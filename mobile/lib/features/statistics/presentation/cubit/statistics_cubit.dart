import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cineplex_mobile/features/statistics/data/repositories/statistics_repository.dart';
import 'package:cineplex_mobile/features/statistics/data/models/statistics_model.dart';

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
  final String currentTimeFrame;
  final int? selectedYear;
  final int? selectedMonth;

  const StatisticsLoaded({
    required this.summary,
    required this.revenuePeriods,
    required this.movies,
    this.currentTimeFrame = 'month',
    this.selectedYear,
    this.selectedMonth,
  });

  @override
  List<Object?> get props => [
        summary,
        revenuePeriods,
        movies,
        currentTimeFrame,
        selectedYear,
        selectedMonth,
      ];

  StatisticsLoaded copyWith({
    SummaryModel? summary,
    List<RevenuePeriodModel>? revenuePeriods,
    List<MoviePerformanceModel>? movies,
    String? currentTimeFrame,
    int? selectedYear,
    int? selectedMonth,
  }) {
    return StatisticsLoaded(
      summary: summary ?? this.summary,
      revenuePeriods: revenuePeriods ?? this.revenuePeriods,
      movies: movies ?? this.movies,
      currentTimeFrame: currentTimeFrame ?? this.currentTimeFrame,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
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

  Future<void> loadStats({
    String timeFrame = 'month',
    int? year,
    int? month,
  }) async {
    emit(StatisticsLoading());
    try {
      final now = DateTime.now();
      final effectiveYear = year ?? now.year;

      final results = await Future.wait([
        repository.getSummary(),
        repository.getRevenueStatistics(timeFrame: timeFrame, year: effectiveYear, month: month),
        repository.getMoviePerformance(),
      ]);

      emit(StatisticsLoaded(
        summary: results[0] as SummaryModel,
        revenuePeriods: results[1] as List<RevenuePeriodModel>,
        movies: results[2] as List<MoviePerformanceModel>,
        currentTimeFrame: timeFrame,
        selectedYear: effectiveYear,
        selectedMonth: month,
      ));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }

  Future<void> updateTimeFrame(String timeFrame, {int? year, int? month}) async {
    final currentState = state;
    if (currentState is! StatisticsLoaded) {
      await loadStats(timeFrame: timeFrame, year: year, month: month);
      return;
    }

    try {
      final revenue = await repository.getRevenueStatistics(
        timeFrame: timeFrame,
        year: year ?? currentState.selectedYear,
        month: month,
      );

      emit(currentState.copyWith(
        revenuePeriods: revenue,
        currentTimeFrame: timeFrame,
        selectedYear: year ?? currentState.selectedYear,
        selectedMonth: month,
      ));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }
}
