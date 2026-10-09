import 'package:cineplex_staff/features/ticket_sale/presentation/cubit/ticket_sale_cubit.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/cubit/ticket_sale_state.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/screens/ticket_sale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class _FakeCinemaRepo implements CinemaManagementRepository {
  final List<CinemaModel> cinemas;
  _FakeCinemaRepo(this.cinemas);

  @override
  Future<List<CinemaModel>> getAllCinemas({int page = 1, int pageSize = 50}) async => cinemas;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeShowtimeRepo implements ShowtimeManagementRepository {
  final Map<int, Map<String, dynamic>> showtimesByCinema;
  _FakeShowtimeRepo(this.showtimesByCinema);

  @override
  Future<Map<String, dynamic>> getByCinemaId(int cinemaId) async {
    return showtimesByCinema[cinemaId] ?? {};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBookingRepo implements BookingManagementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const cinema1 = CinemaModel(
    id: 1,
    name: 'Cineplex Landmark 81',
    address: 'Bình Thạnh, TP.HCM',
    phone: '0901234567',
    email: 'landmark@cineplex.vn',
    status: 'ACTIVE',
  );

  const cinema2 = CinemaModel(
    id: 2,
    name: 'Cineplex Quận 1',
    address: 'Quận 1, TP.HCM',
    phone: '0901234568',
    email: 'quan1@cineplex.vn',
    status: 'ACTIVE',
  );

  final now = DateTime.now();
  final showtimeTime = now.add(const Duration(hours: 2));
  final dateKey = '${showtimeTime.year}-${showtimeTime.month.toString().padLeft(2, '0')}-${showtimeTime.day.toString().padLeft(2, '0')}';

  final showtimesCinema1 = {
    dateKey: [
      {
        'id': 101,
        'movieId': 1,
        'roomId': 1,
        'format': 'FORMAT_2D',
        'status': 'SCHEDULED',
        'publicStartTime': showtimeTime.toIso8601String(),
        'pricePerSeat': 85000,
        'totalSeats': 100,
        'availableSeats': 80,
        'movie': {
          'id': 1,
          'title': 'Dune: Part Two',
          'genre': 'Sci-Fi',
          'durationMinutes': 166,
          'status': 'NOW_SHOWING',
        },
        'room': {
          'id': 1,
          'cinemaId': 1,
          'name': 'Phòng 01',
          'roomType': 'STANDARD',
          'totalSeats': 100,
          'rows': 10,
          'columns': 10,
          'isCouple': false,
          'status': 'ACTIVE',
        },
      },
      // Stray showtime with mismatched room.cinemaId = 2 should be rejected
      {
        'id': 102,
        'movieId': 2,
        'roomId': 2,
        'format': 'FORMAT_2D',
        'status': 'SCHEDULED',
        'publicStartTime': showtimeTime.toIso8601String(),
        'pricePerSeat': 90000,
        'totalSeats': 80,
        'availableSeats': 70,
        'movie': {
          'id': 2,
          'title': 'Kung Fu Panda 4',
          'genre': 'Animation',
          'durationMinutes': 94,
          'status': 'NOW_SHOWING',
        },
        'room': {
          'id': 2,
          'cinemaId': 2,
          'name': 'Phòng 02',
          'roomType': 'STANDARD',
          'totalSeats': 80,
          'rows': 8,
          'columns': 10,
          'isCouple': false,
          'status': 'ACTIVE',
        },
      },
    ],
  };

  final showtimesCinema2 = {
    dateKey: [
      {
        'id': 201,
        'movieId': 2,
        'roomId': 3,
        'format': 'FORMAT_2D',
        'status': 'SCHEDULED',
        'publicStartTime': showtimeTime.toIso8601String(),
        'pricePerSeat': 90000,
        'totalSeats': 80,
        'availableSeats': 70,
        'movie': {
          'id': 2,
          'title': 'Kung Fu Panda 4',
          'genre': 'Animation',
          'durationMinutes': 94,
          'status': 'NOW_SHOWING',
        },
        'room': {
          'id': 3,
          'cinemaId': 2,
          'name': 'Phòng 03',
          'roomType': 'STANDARD',
          'totalSeats': 80,
          'rows': 8,
          'columns': 10,
          'isCouple': false,
          'status': 'ACTIVE',
        },
      },
    ],
  };

  group('Staff Ticket Sale Fixed Cinema Tests', () {
    test('TicketSaleCubit locks cinema and filters showtimes when defaultCinemaId is set', () async {
      final cinemaRepo = _FakeCinemaRepo([cinema1, cinema2]);
      final showtimeRepo = _FakeShowtimeRepo({
        1: showtimesCinema1,
        2: showtimesCinema2,
      });
      final bookingRepo = _FakeBookingRepo();

      final cubit = TicketSaleCubit(cinemaRepo, showtimeRepo, bookingRepo);
      await cubit.loadInitialData(defaultCinemaId: 1);

      expect(cubit.state, isA<TicketSaleLoaded>());
      final loaded = cubit.state as TicketSaleLoaded;

      // Cinema must be fixed to 1
      expect(loaded.isCinemaFixed, isTrue);
      expect(loaded.selectedCinemaId, equals(1));
      expect(loaded.cinemas.length, equals(1));
      expect(loaded.cinemas.first.name, equals('Cineplex Landmark 81'));

      // Only movies and showtimes for cinema 1 (Dune: Part Two)
      expect(loaded.moviesForCinema.length, equals(1));
      expect(loaded.moviesForCinema.first.title, equals('Dune: Part Two'));
      expect(loaded.cinemaShowtimes.length, equals(1));
      expect(loaded.cinemaShowtimes.first.id, equals(101));

      // Attempting to select cinema 2 must be blocked
      await cubit.selectCinema(2);
      final afterSwitchAttempt = cubit.state as TicketSaleLoaded;
      expect(afterSwitchAttempt.selectedCinemaId, equals(1));
      expect(afterSwitchAttempt.moviesForCinema.first.title, equals('Dune: Part Two'));
    });

    test('TicketSaleCubit allows selecting cinema when defaultCinemaId is null (unassigned)', () async {
      final cinemaRepo = _FakeCinemaRepo([cinema1, cinema2]);
      final showtimeRepo = _FakeShowtimeRepo({
        1: showtimesCinema1,
        2: showtimesCinema2,
      });
      final bookingRepo = _FakeBookingRepo();

      final cubit = TicketSaleCubit(cinemaRepo, showtimeRepo, bookingRepo);
      await cubit.loadInitialData();

      expect(cubit.state, isA<TicketSaleLoaded>());
      final loaded = cubit.state as TicketSaleLoaded;

      expect(loaded.isCinemaFixed, isFalse);
      expect(loaded.cinemas.length, equals(2));
      expect(loaded.selectedCinemaId, equals(1));

      // Can switch to cinema 2
      await cubit.selectCinema(2);
      final loaded2 = cubit.state as TicketSaleLoaded;
      expect(loaded2.selectedCinemaId, equals(2));
      expect(loaded2.moviesForCinema.length, equals(1));
      expect(loaded2.moviesForCinema.first.title, equals('Kung Fu Panda 4'));
    });

    testWidgets('TicketSaleScreen renders non-editable fixed cinema header when isCinemaFixed is true', (tester) async {
      final cinemaRepo = _FakeCinemaRepo([cinema1, cinema2]);
      final showtimeRepo = _FakeShowtimeRepo({
        1: showtimesCinema1,
      });
      final bookingRepo = _FakeBookingRepo();

      final cubit = TicketSaleCubit(cinemaRepo, showtimeRepo, bookingRepo);
      await cubit.loadInitialData(defaultCinemaId: 1);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: TicketSaleScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      // Fixed cinema header elements
      expect(find.text('Cineplex Landmark 81'), findsOneWidget);
      expect(find.text('Chi nhánh'), findsOneWidget);
      expect(find.byIcon(LucideIcons.mapPin), findsWidgets);

      // Must NOT find DropdownButton
      expect(find.byType(DropdownButton<int>), findsNothing);

      // Movie Dune: Part Two is present
      expect(find.text('Dune: Part Two'), findsOneWidget);
    });

    testWidgets('TicketSaleScreen renders cleanly in Light Mode without contrast issues', (tester) async {
      final cinemaRepo = _FakeCinemaRepo([cinema1, cinema2]);
      final showtimeRepo = _FakeShowtimeRepo({
        1: showtimesCinema1,
      });
      final bookingRepo = _FakeBookingRepo();

      final cubit = TicketSaleCubit(cinemaRepo, showtimeRepo, bookingRepo);
      await cubit.loadInitialData(defaultCinemaId: 1);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: TicketSaleScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cineplex Landmark 81'), findsOneWidget);
      expect(find.text('Chi nhánh'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
