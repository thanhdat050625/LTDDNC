import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineplex_mobile/core/services/socket_service.dart';
import 'package:cineplex_mobile/features/booking/data/models/seat_model.dart';
import 'package:cineplex_mobile/features/booking/data/repositories/booking_repository.dart';
import 'package:cineplex_mobile/features/showtime/data/models/cinema_model.dart';

abstract class SeatBookingEvent extends Equatable {
  const SeatBookingEvent();
  @override
  List<Object?> get props => [];
}

class LoadSeatMap extends SeatBookingEvent {
  final int showtimeId;
  const LoadSeatMap(this.showtimeId);
  @override
  List<Object?> get props => [showtimeId];
}

class SelectSeat extends SeatBookingEvent {
  final int seatId;
  const SelectSeat(this.seatId);
  @override
  List<Object?> get props => [seatId];
}

class DeselectSeat extends SeatBookingEvent {
  final int seatId;
  const DeselectSeat(this.seatId);
  @override
  List<Object?> get props => [seatId];
}

class HoldSelectedSeats extends SeatBookingEvent {}

class SeatUpdateReceived extends SeatBookingEvent {
  final Map<String, dynamic> data;
  const SeatUpdateReceived(this.data);
  @override
  List<Object?> get props => [data];
}

class TimerTick extends SeatBookingEvent {
  final int secondsRemaining;
  const TimerTick(this.secondsRemaining);
  @override
  List<Object?> get props => [secondsRemaining];
}

abstract class SeatBookingState extends Equatable {
  const SeatBookingState();
  @override
  List<Object?> get props => [];
}

class SeatBookingInitial extends SeatBookingState {}
class SeatMapLoading extends SeatBookingState {}

class SeatMapLoaded extends SeatBookingState {
  final List<SeatModel> seats;
  final List<int> selectedSeatIds;
  final List<int> heldSeatIds;
  final List<int> bookedSeatIds;
  final RoomModel? roomInfo;
  final double pricePerSeat;
  final int? secondsRemaining;
  final int? bookingId;

  const SeatMapLoaded({
    required this.seats,
    this.selectedSeatIds = const [],
    this.heldSeatIds = const [],
    this.bookedSeatIds = const [],
    this.roomInfo,
    this.pricePerSeat = 0.0,
    this.secondsRemaining,
    this.bookingId,
  });

  SeatMapLoaded copyWith({
    List<SeatModel>? seats,
    List<int>? selectedSeatIds,
    List<int>? heldSeatIds,
    List<int>? bookedSeatIds,
    RoomModel? roomInfo,
    double? pricePerSeat,
    int? secondsRemaining,
    int? bookingId,
  }) {
    return SeatMapLoaded(
      seats: seats ?? this.seats,
      selectedSeatIds: selectedSeatIds ?? this.selectedSeatIds,
      heldSeatIds: heldSeatIds ?? this.heldSeatIds,
      bookedSeatIds: bookedSeatIds ?? this.bookedSeatIds,
      roomInfo: roomInfo ?? this.roomInfo,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  @override
  List<Object?> get props => [seats, selectedSeatIds, heldSeatIds, bookedSeatIds, roomInfo, pricePerSeat, secondsRemaining, bookingId];
}

class SeatBookingError extends SeatBookingState {
  final String message;
  const SeatBookingError(this.message);
  @override
  List<Object?> get props => [message];
}

class SeatsHeld extends SeatBookingState {
  final int bookingId;
  final DateTime expiredAt;
  const SeatsHeld(this.bookingId, this.expiredAt);
  @override
  List<Object?> get props => [bookingId, expiredAt];
}

class BookingCreated extends SeatBookingState {
  final int bookingId;
  const BookingCreated(this.bookingId);
  @override
  List<Object?> get props => [bookingId];
}

class SeatBookingBloc extends Bloc<SeatBookingEvent, SeatBookingState> {
  final BookingRepository _repository;
  final SocketService _socketService;
  int? _currentShowtimeId;
  StreamSubscription? _timerSubscription;

  SeatBookingBloc(this._repository, this._socketService) : super(SeatBookingInitial()) {
    on<LoadSeatMap>(_onLoadSeatMap);
    on<SelectSeat>(_onSelectSeat);
    on<DeselectSeat>(_onDeselectSeat);
    on<HoldSelectedSeats>(_onHoldSelectedSeats);
    on<SeatUpdateReceived>(_onSeatUpdateReceived);
    on<TimerTick>(_onTimerTick);
  }

  Future<void> _onLoadSeatMap(LoadSeatMap event, Emitter<SeatBookingState> emit) async {
    emit(SeatMapLoading());
    try {
      _currentShowtimeId = event.showtimeId;
      _socketService.joinShowtime(event.showtimeId);
      _socketService.onSeatUpdate((data) {
        add(SeatUpdateReceived(data));
      });

      // Simulating API call for showtime detail which contains seats
      // Normally would call repository.getShowtimeDetail but we use unavailable seats as proxy
      final unavailable = await _repository.getUnavailableSeats(event.showtimeId);
      
      // Mocked seats since we don't have getShowtimeDetail in BookingRepository
      // Real app would fetch full detail here
      final List<SeatModel> seats = [];
      
      emit(SeatMapLoaded(
        seats: seats,
        heldSeatIds: List<int>.from(unavailable['heldSeatIds'] ?? []),
        bookedSeatIds: List<int>.from(unavailable['bookedSeatIds'] ?? []),
        pricePerSeat: 50000,
      ));
    } catch (e) {
      emit(SeatBookingError(e.toString()));
    }
  }

  void _onSelectSeat(SelectSeat event, Emitter<SeatBookingState> emit) {
    if (state is SeatMapLoaded) {
      final s = state as SeatMapLoaded;
      if (s.selectedSeatIds.length >= 8) {
        // Max seats
        return;
      }
      if (s.heldSeatIds.contains(event.seatId) || s.bookedSeatIds.contains(event.seatId)) {
        return;
      }
      emit(s.copyWith(selectedSeatIds: [...s.selectedSeatIds, event.seatId]));
    }
  }

  void _onDeselectSeat(DeselectSeat event, Emitter<SeatBookingState> emit) {
    if (state is SeatMapLoaded) {
      final s = state as SeatMapLoaded;
      emit(s.copyWith(selectedSeatIds: s.selectedSeatIds.where((id) => id != event.seatId).toList()));
    }
  }

  Future<void> _onHoldSelectedSeats(HoldSelectedSeats event, Emitter<SeatBookingState> emit) async {
    if (state is SeatMapLoaded && _currentShowtimeId != null) {
      final s = state as SeatMapLoaded;
      if (s.selectedSeatIds.isEmpty) return;
      
      try {
        final res = await _repository.holdSeats(_currentShowtimeId!, s.selectedSeatIds);
        final expiredAt = DateTime.parse(res['expiredAt']).toLocal();
        final bookingId = res['bookingId'] ?? 0;
        
        _startTimer(300);
        
        emit(SeatsHeld(bookingId, expiredAt));
      } catch (e) {
        emit(SeatBookingError(e.toString()));
      }
    }
  }

  void _onSeatUpdateReceived(SeatUpdateReceived event, Emitter<SeatBookingState> emit) {
    if (state is SeatMapLoaded) {
      final s = state as SeatMapLoaded;
      final held = List<int>.from(event.data['heldSeatIds'] ?? []);
      final booked = List<int>.from(event.data['bookedSeatIds'] ?? []);
      
      // Remove any selected seats that are now held/booked by others
      final newSelected = s.selectedSeatIds.where((id) => !held.contains(id) && !booked.contains(id)).toList();
      
      emit(s.copyWith(
        heldSeatIds: held,
        bookedSeatIds: booked,
        selectedSeatIds: newSelected,
      ));
    }
  }

  void _onTimerTick(TimerTick event, Emitter<SeatBookingState> emit) {
    if (state is SeatMapLoaded) {
      emit((state as SeatMapLoaded).copyWith(secondsRemaining: event.secondsRemaining));
    }
  }

  void _startTimer(int seconds) {
    _timerSubscription?.cancel();
    int current = seconds;
    _timerSubscription = Stream.periodic(const Duration(seconds: 1), (i) => current - i - 1).take(seconds).listen((remaining) {
      add(TimerTick(remaining));
    });
  }

  @override
  Future<void> close() {
    if (_currentShowtimeId != null) {
      _socketService.leaveShowtime(_currentShowtimeId!);
      _socketService.offSeatUpdate();
    }
    _timerSubscription?.cancel();
    return super.close();
  }
}
