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
  const StatisticsLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
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

  Future<void> loadStats() async {
    emit(StatisticsLoading());
    try {
      final summary = await repository.getSummary();
      emit(StatisticsLoaded(summary));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }
}
