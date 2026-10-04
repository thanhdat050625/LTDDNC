import 'package:cineplex_staff/features/ticket_sale/data/models/checkout_args.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

void main() {
  group('CheckoutArgs & CheckoutScreen Unit and Widget Tests', () {
    final showtime = ShowtimeModel(
      id: 101,
      movieId: 1,
      roomId: 1,
      format: '2D',
      publicStartTime: DateTime.now().add(const Duration(hours: 2)),
      pricePerSeat: 85000,
      status: 'SCHEDULED',
      movie: const MovieModel(
        id: 1,
        title: 'Dune: Part Two',
        genre: 'Sci-Fi',
        durationMinutes: 166,
        status: 'NOW_SHOWING',
      ),
      room: const RoomModel(
        id: 1,
        cinemaId: 1,
        name: 'Phòng 02',
        roomType: 'IMAX',
        totalSeats: 120,
        rows: 10,
        columns: 12,
        isCouple: false,
        status: 'ACTIVE',
      ),
    );

    final List<SeatModel> seats = [
      const SeatModel(
        seatId: 10,
        row: 'F',
        column: 5,
        label: 'F5',
        status: SeatStatus.available,
        isCouple: false,
      ),
      const SeatModel(
        seatId: 11,
        row: 'F',
        column: 6,
        label: 'F6',
        status: SeatStatus.available,
        isCouple: false,
      ),
    ];

    final concessions = [
      const SelectedConcession(
        name: 'Bắp rang bơ',
        productId: 1,
        price: 55000,
        quantity: 2,
      ),
    ];

    test('CheckoutArgs calculates totals accurately', () {
      final args = CheckoutArgs(
        showtime: showtime,
        selectedSeats: seats,
        concessions: concessions,
        pointsToUse: 10000,
      );

      // 2 tickets * 85000 = 170000
      expect(args.ticketTotal, equals(170000));
      // 2 popcorns * 55000 = 110000
      expect(args.concessionTotal, equals(110000));
      // Grand total: 170000 + 110000 - 10000 = 270000
      expect(args.grandTotal, equals(270000));
    });

    testWidgets('CheckoutScreen renders dynamic movie title, seats, and totals from CheckoutArgs', (
      tester,
    ) async {
      final args = CheckoutArgs(
        showtime: showtime,
        selectedSeats: seats,
        concessions: concessions,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: CheckoutScreen(args: args),
        ),
      );

      await tester.pump();

      final l10n = AppLocalizations.of(tester.element(find.byType(CheckoutScreen)))!;

      // Verify Movie title rendered from args
      expect(find.text('Dune: Part Two'), findsOneWidget);

      // Verify Seat chips rendered
      expect(find.text('F5'), findsOneWidget);
      expect(find.text('F6'), findsOneWidget);

      // Verify Payment breakdown labels
      expect(find.text(l10n.paymentMethod), findsOneWidget);
      expect(find.text(l10n.orderSummary), findsOneWidget);
      expect(find.text(l10n.payNow), findsOneWidget);
    });
  });
}
