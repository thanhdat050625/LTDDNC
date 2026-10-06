import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/booking/data/repositories/booking_repository.dart';

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

  double get totalPrice {
    double total = 0.0;
    for (final seatId in selectedSeatIds) {
      final seat = seats.where((s) => s.seatId == seatId).firstOrNull;
      if (seat != null) {
        if (seat.price > 0) {
          total += seat.price;
        } else if (seat.isCouple) {
          total += pricePerSeat + 30000;
        } else if (seat.isVip) {
          total += pricePerSeat + 20000;
        } else {
          total += pricePerSeat;
        }
      } else {
        total += pricePerSeat;
      }
    }
    return total;
  }

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

      // 1. Lấy thông tin phòng chiếu và ghế thật từ Backend API
      Map<String, dynamic> showtimeDetail = {};
      try {
        showtimeDetail = await _repository.getShowtimeDetail(event.showtimeId);
      } catch (_) {
        // Fallback cho test/mạng
      }

      final roomData = showtimeDetail['room'] as Map<String, dynamic>?;
      final roomInfo = roomData != null ? RoomModel.fromJson(roomData) : null;
      final rawSeats = (showtimeDetail['seats'] as List<dynamic>?) ??
          (roomData != null ? (roomData['seats'] as List<dynamic>?) : null) ??
          [];
      final List<SeatModel> seats = rawSeats
          .map((e) => SeatModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final double pricePerSeat =
          (showtimeDetail['pricePerSeat'] as num?)?.toDouble() ?? 50000.0;

      // 2. Lấy danh sách ghế đang bị giữ (Redis) hoặc đã đặt (CONFIRMED)
      final unavailable = await _repository.getUnavailableSeats(event.showtimeId);
      final heldSeatIds = List<int>.from(unavailable['heldSeatIds'] ?? []);
      final bookedSeatIds = List<int>.from(unavailable['bookedSeatIds'] ?? []);

      // 3. Cập nhật status của từng seat trong list
      final updatedSeats = seats.map((seat) {
        if (bookedSeatIds.contains(seat.seatId)) {
          return seat.copyWith(status: SeatStatus.booked);
        }
        if (heldSeatIds.contains(seat.seatId)) {
          return seat.copyWith(status: SeatStatus.held);
        }
        return seat;
      }).toList();

      emit(SeatMapLoaded(
        seats: updatedSeats,
        heldSeatIds: heldSeatIds,
        bookedSeatIds: bookedSeatIds,
        roomInfo: roomInfo,
        pricePerSeat: pricePerSeat,
      ));
    } catch (e) {
      emit(SeatBookingError(e.toString()));
    }
  }

  void _onSelectSeat(SelectSeat event, Emitter<SeatBookingState> emit) {
    if (state is! SeatMapLoaded) return;
    final s = state as SeatMapLoaded;

    if (s.selectedSeatIds.length >= 8) {
      emit(const SeatBookingError('Chỉ được chọn tối đa 8 ghế mỗi đơn hàng'));
      emit(s);
      return;
    }
    if (s.heldSeatIds.contains(event.seatId) || s.bookedSeatIds.contains(event.seatId)) {
      return;
    }

    emit(s.copyWith(selectedSeatIds: [...s.selectedSeatIds, event.seatId]));
  }

  Future<void> _onDeselectSeat(DeselectSeat event, Emitter<SeatBookingState> emit) async {
    if (state is! SeatMapLoaded) return;
    final s = state as SeatMapLoaded;

    final newSelected = s.selectedSeatIds.where((id) => id != event.seatId).toList();
    emit(s.copyWith(selectedSeatIds: newSelected));

    if (newSelected.isEmpty) {
      _timerSubscription?.cancel();
      emit(s.copyWith(selectedSeatIds: newSelected, secondsRemaining: null));
    }

    if (_currentShowtimeId != null) {
      try {
        await _repository.releaseSeats(_currentShowtimeId!, [event.seatId]);
      } catch (_) {
        // Lỗi mạng không được chặn UI (UC07 A3.1)
      }
    }
  }

  Future<void> _onHoldSelectedSeats(HoldSelectedSeats event, Emitter<SeatBookingState> emit) async {
    if (state is! SeatMapLoaded || _currentShowtimeId == null) return;
    final s = state as SeatMapLoaded;
    if (s.selectedSeatIds.isEmpty) return;

    try {
      final res = await _repository.holdSeats(_currentShowtimeId!, s.selectedSeatIds);
      DateTime? holdExpiredAt;
      if (res['expiredAt'] != null) {
        holdExpiredAt = DateTime.tryParse(res['expiredAt'].toString())?.toLocal();
      }

      final booking = await _repository.createBooking(CreateBookingDto(
        showtimeId: _currentShowtimeId!,
        seatIds: s.selectedSeatIds,
      ));

      if (booking.id <= 0) {
        emit(const SeatBookingError('Không thể tạo đơn đặt vé'));
        emit(s);
        return;
      }

      final expiredAt = booking.expiredAt ?? holdExpiredAt ?? DateTime.now().add(const Duration(minutes: 5));
      final diff = expiredAt.difference(DateTime.now()).inSeconds;
      _startTimer(diff > 0 ? diff : 300);

      emit(SeatsHeld(booking.id, expiredAt));
    } catch (e) {
      emit(SeatBookingError(_mapBookingError(e)));
      emit(s);
    }
  }

  String _mapBookingError(Object e) {
    if (e is ServerException) {
      switch (e.code) {
        case 'SEAT_ALREADY_BOOKED':
        case 'SEAT_ALREADY_HELD':
        case 'SEAT_NOT_HELD':
          return 'Ghế đã có người giữ hoặc đã được đặt';
        case 'MAX_SEATS_EXCEEDED':
          return 'Chỉ được chọn tối đa 8 ghế mỗi đơn hàng';
        case 'SHOWTIME_EXPIRED':
          return 'Suất chiếu đã bắt đầu hoặc không còn khả dụng';
        case 'SEAT_ROOM_MISMATCH':
          return 'Ghế được chọn không thuộc phòng chiếu này';
        default:
          return e.message;
      }
    }
    return e.toString();
  }

  void _onSeatUpdateReceived(SeatUpdateReceived event, Emitter<SeatBookingState> emit) {
    if (state is SeatMapLoaded) {
      final s = state as SeatMapLoaded;
      final held = List<int>.from(event.data['heldSeatIds'] ?? []);
      final booked = List<int>.from(event.data['bookedSeatIds'] ?? []);

      final newSelected = s.selectedSeatIds.where((id) => !booked.contains(id)).toList();

      final updatedSeats = s.seats.map((seat) {
        if (booked.contains(seat.seatId)) {
          return seat.copyWith(status: SeatStatus.booked);
        }
        if (held.contains(seat.seatId) && !newSelected.contains(seat.seatId)) {
          return seat.copyWith(status: SeatStatus.held);
        }
        if (!held.contains(seat.seatId) && !booked.contains(seat.seatId)) {
          return seat.copyWith(status: SeatStatus.available);
        }
        return seat;
      }).toList();

      emit(s.copyWith(
        seats: updatedSeats,
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
