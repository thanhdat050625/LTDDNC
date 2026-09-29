import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/showtime/data/repositories/showtime_repository.dart';

abstract class ShowtimeState extends Equatable {
  const ShowtimeState();
  @override
  List<Object> get props => [];
}

class ShowtimeInitial extends ShowtimeState {}

class ShowtimeLoading extends ShowtimeState {}

class ShowtimeLoaded extends ShowtimeState {
  final Map<String, List<ShowtimeModel>> showtimes;
  const ShowtimeLoaded(this.showtimes);

  @override
  List<Object> get props => [showtimes];
}

class ShowtimeError extends ShowtimeState {
  final String message;
  const ShowtimeError(this.message);

  @override
  List<Object> get props => [message];
}

class ShowtimeCubit extends Cubit<ShowtimeState> {
  final ShowtimeRepository _repository;

  ShowtimeCubit(this._repository) : super(ShowtimeInitial());

  Future<void> loadShowtimes(int movieId) async {
    emit(ShowtimeLoading());
    try {
      final showtimes = await _repository.getShowtimesByMovie(movieId);
      emit(ShowtimeLoaded(showtimes));
    } catch (e) {
      emit(ShowtimeError(e.toString()));
    }
  }
}
