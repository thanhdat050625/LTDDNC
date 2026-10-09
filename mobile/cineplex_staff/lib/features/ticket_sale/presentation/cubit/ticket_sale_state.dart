import 'package:mobile_shared/mobile_shared.dart';

abstract class TicketSaleState {}

class TicketSaleInitial extends TicketSaleState {}

class TicketSaleLoading extends TicketSaleState {}

class TicketSaleLoaded extends TicketSaleState {
  final List<CinemaModel> cinemas;
  final int? selectedCinemaId;
  final bool isCinemaFixed;
  final List<ShowtimeModel> cinemaShowtimes;
  final List<MovieModel> moviesForCinema;
  final int? selectedMovieId;
  final ShowtimeModel? selectedShowtime;
  final List<SeatModel> seats;
  final List<SeatModel> selectedSeats;

  TicketSaleLoaded({
    required this.cinemas,
    this.selectedCinemaId,
    this.isCinemaFixed = false,
    this.cinemaShowtimes = const [],
    this.moviesForCinema = const [],
    this.selectedMovieId,
    this.selectedShowtime,
    this.seats = const [],
    this.selectedSeats = const [],
  });

  TicketSaleLoaded copyWith({
    List<CinemaModel>? cinemas,
    int? selectedCinemaId,
    bool? isCinemaFixed,
    List<ShowtimeModel>? cinemaShowtimes,
    List<MovieModel>? moviesForCinema,
    int? selectedMovieId,
    ShowtimeModel? selectedShowtime,
    List<SeatModel>? seats,
    List<SeatModel>? selectedSeats,
  }) {
    return TicketSaleLoaded(
      cinemas: cinemas ?? this.cinemas,
      selectedCinemaId: selectedCinemaId ?? this.selectedCinemaId,
      isCinemaFixed: isCinemaFixed ?? this.isCinemaFixed,
      cinemaShowtimes: cinemaShowtimes ?? this.cinemaShowtimes,
      moviesForCinema: moviesForCinema ?? this.moviesForCinema,
      selectedMovieId: selectedMovieId ?? this.selectedMovieId,
      selectedShowtime: selectedShowtime ?? this.selectedShowtime,
      seats: seats ?? this.seats,
      selectedSeats: selectedSeats ?? this.selectedSeats,
    );
  }
}

class TicketSaleError extends TicketSaleState {
  final String message;
  TicketSaleError(this.message);
}
