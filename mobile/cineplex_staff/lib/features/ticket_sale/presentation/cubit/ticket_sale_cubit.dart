import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

import 'ticket_sale_state.dart';

class TicketSaleCubit extends Cubit<TicketSaleState> {
  final CinemaManagementRepository _cinemaRepo;
  final ShowtimeManagementRepository _showtimeRepo;
  final BookingManagementRepository _bookingRepo;

  TicketSaleCubit(this._cinemaRepo, this._showtimeRepo, this._bookingRepo)
    : super(TicketSaleInitial());

  Future<void> loadInitialData() async {
    emit(TicketSaleLoading());
    try {
      final cinemas = await _cinemaRepo.getAllCinemas();
      if (cinemas.isEmpty) {
        emit(TicketSaleLoaded(cinemas: [], selectedCinemaId: null));
        return;
      }

      final firstCinema = cinemas.first;
      final showtimesData = await _showtimeRepo.getByCinemaId(firstCinema.id);
      final List<ShowtimeModel> showtimes = _parseShowtimes(showtimesData);

      final movies = _extractMovies(showtimes);

      emit(
        TicketSaleLoaded(
          cinemas: cinemas,
          selectedCinemaId: firstCinema.id,
          cinemaShowtimes: showtimes,
          moviesForCinema: movies,
          selectedMovieId: movies.isNotEmpty ? movies.first.id : null,
        ),
      );
    } catch (e) {
      emit(TicketSaleError(e.toString()));
    }
  }

  Future<void> selectCinema(int cinemaId) async {
    if (state is TicketSaleLoaded) {
      final currentState = state as TicketSaleLoaded;
      emit(TicketSaleLoading());
      try {
        final showtimesData = await _showtimeRepo.getByCinemaId(cinemaId);
        final List<ShowtimeModel> showtimes = _parseShowtimes(showtimesData);
        final movies = _extractMovies(showtimes);

        emit(
          TicketSaleLoaded(
            cinemas: currentState.cinemas,
            selectedCinemaId: cinemaId,
            cinemaShowtimes: showtimes,
            moviesForCinema: movies,
            selectedMovieId: movies.isNotEmpty ? movies.first.id : null,
          ),
        );
      } catch (e) {
        emit(TicketSaleError(e.toString()));
      }
    }
  }

  void selectMovie(int movieId) {
    if (state is TicketSaleLoaded) {
      final currentState = state as TicketSaleLoaded;
      emit(currentState.copyWith(selectedMovieId: movieId));
    }
  }

  Future<void> selectShowtime(ShowtimeModel showtime) async {
    if (state is TicketSaleLoaded) {
      final currentState = state as TicketSaleLoaded;
      emit(
        currentState.copyWith(
          selectedShowtime: showtime,
          seats: [],
          selectedSeats: [],
        ),
      );

      try {
        final seats = await _bookingRepo.getShowtimeSeats(showtime.id);
        if (state is TicketSaleLoaded) {
          emit((state as TicketSaleLoaded).copyWith(seats: seats));
        }
      } catch (e) {
        emit(TicketSaleError(e.toString()));
      }
    }
  }

  void toggleSeat(SeatModel seat) {
    if (state is TicketSaleLoaded) {
      final currentState = state as TicketSaleLoaded;
      final selected = List<SeatModel>.from(currentState.selectedSeats);

      if (selected.any((s) => s.seatId == seat.seatId)) {
        selected.removeWhere((s) => s.seatId == seat.seatId);
      } else {
        selected.add(seat);
      }
      emit(currentState.copyWith(selectedSeats: selected));
    }
  }

  Future<bool> holdSelectedSeats() async {
    if (state is TicketSaleLoaded) {
      final currentState = state as TicketSaleLoaded;
      if (currentState.selectedShowtime == null ||
          currentState.selectedSeats.isEmpty) {
        return false;
      }

      try {
        final seatIds = currentState.selectedSeats
            .map((s) => s.seatId)
            .toList();
        return await _bookingRepo.holdSeats(
          currentState.selectedShowtime!.id,
          seatIds,
        );
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  List<ShowtimeModel> _parseShowtimes(Map<String, dynamic> data) {
    final List<ShowtimeModel> allShowtimes = [];
    final now = DateTime.now();
    final endOfTomorrow = DateTime(now.year, now.month, now.day + 1, 23, 59, 59, 999);

    // The backend returns a map keyed by YYYY-MM-DD
    data.forEach((dateString, list) {
      if (list is List) {
        for (var item in list) {
          final st = ShowtimeModel.fromJson(item as Map<String, dynamic>);
          // Filter: only showtimes from now until end of tomorrow
          if (st.status != 'COMPLETED' &&
              st.status != 'CANCELLED' &&
              st.publicStartTime.isAfter(now) &&
              st.publicStartTime.isBefore(endOfTomorrow)) {
            allShowtimes.add(st);
          }
        }
      }
    });

    // Sort by startTime
    allShowtimes.sort((a, b) => a.publicStartTime.compareTo(b.publicStartTime));
    return allShowtimes;
  }

  List<MovieModel> _extractMovies(List<ShowtimeModel> showtimes) {
    final map = <int, MovieModel>{};
    for (var st in showtimes) {
      if (st.movie != null && !map.containsKey(st.movie!.id)) {
        map[st.movie!.id] = st.movie!;
      }
    }
    return map.values.toList();
  }
}
