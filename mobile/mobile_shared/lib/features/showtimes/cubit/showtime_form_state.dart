import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class ShowtimeFormState extends Equatable {
  const ShowtimeFormState();
  @override
  List<Object?> get props => [];
}

class ShowtimeFormInitial extends ShowtimeFormState {}

class ShowtimeFormLoadingDeps extends ShowtimeFormState {}

class ShowtimeFormDepsLoaded extends ShowtimeFormState {
  final List<MovieModel> movies;
  final List<CinemaModel> cinemas;
  final List<RoomModel> rooms;
  final int? selectedCinemaId;

  const ShowtimeFormDepsLoaded({
    required this.movies,
    required this.cinemas,
    required this.rooms,
    this.selectedCinemaId,
  });

  @override
  List<Object?> get props => [movies, cinemas, rooms, selectedCinemaId];
}

class ShowtimeFormSubmitting extends ShowtimeFormState {}

class ShowtimeFormSuccess extends ShowtimeFormState {
  final ShowtimeModel? showtime;
  const ShowtimeFormSuccess([this.showtime]);
  @override
  List<Object?> get props => [showtime];
}

class ShowtimeFormError extends ShowtimeFormState {
  final String message;
  const ShowtimeFormError(this.message);
  @override
  List<Object?> get props => [message];
}
