import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/booking/presentation/bloc/seat_booking_bloc.dart';
import 'package:cineplex_client/features/booking/data/repositories/booking_repository.dart';

class MockBookingRepository extends Mock implements BookingRepository {}
class MockSocketService extends Mock implements SocketService {}
class FakeCreateBookingDto extends Fake implements CreateBookingDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCreateBookingDto());
  });

  late MockBookingRepository repository;
  late MockSocketService socketService;

  setUp(() {
    repository = MockBookingRepository();
    socketService = MockSocketService();

    when(() => socketService.connectSeat()).thenReturn(null);
    when(() => socketService.joinShowtime(any())).thenReturn(null);
    when(() => socketService.leaveShowtime(any())).thenReturn(null);
    when(() => socketService.onSeatUpdate(any())).thenReturn(null);
    when(() => socketService.offSeatUpdate()).thenReturn(null);
  });

  group('SeatBookingBloc Flow Tests', () {
    test('initial state is SeatBookingInitial', () {
      final bloc = SeatBookingBloc(repository, socketService);
      expect(bloc.state, equals(SeatBookingInitial()));
      bloc.close();
    });

    blocTest<SeatBookingBloc, SeatBookingState>(
      '1. Hold seats -> create booking with real bookingId > 0 emits SeatsHeld',
      build: () {
        when(() => repository.getUnavailableSeats(101)).thenAnswer((_) async => {});
        when(() => repository.holdSeats(101, [1, 2])).thenAnswer((_) async => {
          'expiredAt': '2026-10-06T23:59:59.000Z',
        });
        when(() => repository.createBooking(any())).thenAnswer((_) async => BookingModel(
          id: 999,
          bookingCode: 'BK-REAL-999',
          showtimeId: 101,
          totalAmount: 100000,
          discountAmount: 0,
          pointsUsed: 0,
          status: 'PENDING',
          expiredAt: DateTime.parse('2026-10-06T23:59:59.000Z'),
        ));
        return SeatBookingBloc(repository, socketService);
      },
      act: (bloc) async {
        bloc.add(const LoadSeatMap(101));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const SelectSeat(1));
        bloc.add(const SelectSeat(2));
        bloc.add(HoldSelectedSeats());
      },
      expect: () => [
        isA<SeatMapLoading>(),
        isA<SeatMapLoaded>(),
        isA<SeatMapLoaded>().having((s) => s.selectedSeatIds, 'selected', [1]),
        isA<SeatMapLoaded>().having((s) => s.selectedSeatIds, 'selected', [1, 2]),
        isA<SeatsHeld>()
            .having((s) => s.bookingId, 'bookingId', 999)
            .having((s) => s.expiredAt, 'expiredAt', isNotNull),
      ],
      verify: (_) {
        verify(() => repository.holdSeats(101, [1, 2])).called(1);
        verify(() => repository.createBooking(any(that: isA<CreateBookingDto>()))).called(1);
      },
    );

    blocTest<SeatBookingBloc, SeatBookingState>(
      '2. Hold fails when seats already taken (SEAT_ALREADY_HELD) emits SeatBookingError with localized Vietnamese message',
      build: () {
        when(() => repository.getUnavailableSeats(101)).thenAnswer((_) async => {});
        when(() => repository.holdSeats(101, [1])).thenThrow(
          ServerException('Seat held', code: 'SEAT_ALREADY_HELD'),
        );
        return SeatBookingBloc(repository, socketService);
      },
      act: (bloc) async {
        bloc.add(const LoadSeatMap(101));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const SelectSeat(1));
        bloc.add(HoldSelectedSeats());
      },
      expect: () => [
        isA<SeatMapLoading>(),
        isA<SeatMapLoaded>(),
        isA<SeatMapLoaded>().having((s) => s.selectedSeatIds, 'selected', [1]),
        isA<SeatBookingError>().having((e) => e.message, 'message', 'Ghế đã có người giữ hoặc đã được đặt'),
        isA<SeatMapLoaded>(),
      ],
    );

    blocTest<SeatBookingBloc, SeatBookingState>(
      '3. Reaching 8 seats limit: 9th seat selection emits SeatBookingError MAX_SEATS_EXCEEDED and preserves 8 seats',
      build: () => SeatBookingBloc(repository, socketService),
      seed: () => const SeatMapLoaded(
        seats: [],
        selectedSeatIds: [1, 2, 3, 4, 5, 6, 7, 8],
        pricePerSeat: 50000,
      ),
      act: (bloc) => bloc.add(const SelectSeat(9)),
      expect: () => [
        const SeatBookingError('Chỉ được chọn tối đa 8 ghế mỗi đơn hàng'),
        const SeatMapLoaded(
          seats: [],
          selectedSeatIds: [1, 2, 3, 4, 5, 6, 7, 8],
          pricePerSeat: 50000,
        ),
      ],
    );

    blocTest<SeatBookingBloc, SeatBookingState>(
      '4. Deselecting seat triggers releaseSeats and updates selectedSeatIds without blocking UI on network failure',
      build: () {
        when(() => repository.getUnavailableSeats(101)).thenAnswer((_) async => {});
        when(() => repository.releaseSeats(101, [2])).thenThrow(Exception('Network offline'));
        return SeatBookingBloc(repository, socketService);
      },
      act: (bloc) async {
        bloc.add(const LoadSeatMap(101));
        await Future.delayed(const Duration(milliseconds: 10));
        bloc.add(const SelectSeat(1));
        bloc.add(const SelectSeat(2));
        bloc.add(const DeselectSeat(2));
      },
      expect: () => [
        isA<SeatMapLoading>(),
        isA<SeatMapLoaded>(),
        isA<SeatMapLoaded>().having((s) => s.selectedSeatIds, 'selected', [1]),
        isA<SeatMapLoaded>().having((s) => s.selectedSeatIds, 'selected', [1, 2]),
        // Deselect seat 2 updates state smoothly despite releaseSeats error
        isA<SeatMapLoaded>().having((s) => s.selectedSeatIds, 'selected', [1]),
      ],
      verify: (_) {
        verify(() => repository.releaseSeats(101, [2])).called(1);
      },
    );

    blocTest<SeatBookingBloc, SeatBookingState>(
      '5. Timer ticks down to 0 updates secondsRemaining',
      build: () => SeatBookingBloc(repository, socketService),
      seed: () => const SeatMapLoaded(
        seats: [],
        secondsRemaining: 5,
        pricePerSeat: 50000,
      ),
      act: (bloc) => bloc.add(const TimerTick(0)),
      expect: () => [
        const SeatMapLoaded(
          seats: [],
          secondsRemaining: 0,
          pricePerSeat: 50000,
        ),
      ],
    );
  });
}
