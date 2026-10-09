import 'package:cineplex_staff/features/ticket_sale/data/models/checkout_args.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/screens/checkout_screen.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/screens/payment_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

void main() {
  group('Staff Loyalty Points & Payment Result Tests', () {
    final showtime = ShowtimeModel(
      id: 101,
      movieId: 1,
      roomId: 1,
      format: '2D',
      publicStartTime: DateTime.now().add(const Duration(hours: 2)),
      pricePerSeat: 100000,
      status: 'SCHEDULED',
      movie: const MovieModel(
        id: 1,
        title: 'Lật Mặt 7',
        genre: 'Hành động',
        durationMinutes: 135,
        status: 'NOW_SHOWING',
      ),
      room: const RoomModel(
        id: 1,
        cinemaId: 1,
        name: 'Phòng 01',
        roomType: 'STANDARD',
        totalSeats: 100,
        rows: 10,
        columns: 10,
        isCouple: false,
        status: 'ACTIVE',
      ),
    );

    const customer = UserModel(
      id: 5,
      email: 'khachhang@example.com',
      fullName: 'Nguyễn Văn Khách',
      role: 'CLIENT',
      status: 'ACTIVE',
      loyaltyPoints: 50000,
    );

    final List<SeatModel> seats = [
      const SeatModel(
        seatId: 10,
        row: 'A',
        column: 1,
        label: 'A1',
        status: SeatStatus.available,
        isCouple: false,
      ),
    ];

    testWidgets(
      'CheckoutScreen displays loyalty switch (capped at 20%) & points earned notice',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final args = CheckoutArgs(
          showtime: showtime,
          selectedSeats: seats,
          customer: customer,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('vi')],
            locale: const Locale('vi'),
            home: CheckoutScreen(args: args),
          ),
        );
        await tester.pumpAndSettle();

        final l10n = AppLocalizations.of(tester.element(find.byType(CheckoutScreen)))!;

        // Order subtotal = 100,000đ -> Max 20% = 20,000đ
        // Customer has 50,000 points -> cap is 20,000 points
        expect(find.text(customer.fullName), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);

        // Before toggle: 0 points used, Total = 100,000đ
        // Points earned notice: 10% of 100,000 = 10,000 points
        expect(find.text(l10n.paymentEarnedPointsNotice(10000)), findsOneWidget);

        // Toggle Switch ON
        await tester.ensureVisible(find.byType(Switch));
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Used points badge should appear with 20,000 points
        expect(find.text(l10n.posUsingPointsBadge('20.000')), findsOneWidget);

        // Remaining points: 50,000 - 20,000 = 30,000
        expect(find.text('30.000 ${l10n.pointsSuffix}'), findsOneWidget);

        // Grand total is now 80,000đ -> Points earned notice = 8,000 points
        expect(find.text(l10n.paymentEarnedPointsNotice(8000)), findsOneWidget);

        // Toggle Switch OFF
        await tester.ensureVisible(find.byType(Switch));
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Points reset to 0, earned notice returns to 10,000
        expect(find.text(l10n.paymentEarnedPointsNotice(10000)), findsOneWidget);
      },
    );

    testWidgets(
      'StaffPaymentResultScreen renders receipt with cash change and loyalty reward badge',
      (tester) async {
        final extra = {
          'bookingId': '123',
          'bookingCode': 'BK-TEST-123',
          'status': 'PAID',
          'totalAmount': 80000,
          'method': 'CASH',
          'cashReceived': 100000,
          'cashChange': 20000,
          'customer': customer,
          'pointsUsed': 20000,
          'pointsEarned': 8000,
          'showtime': showtime,
          'selectedSeats': seats,
        };

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('vi')],
            locale: const Locale('vi'),
            home: StaffPaymentResultScreen(
              bookingId: '123',
              initialData: extra,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final l10n = AppLocalizations.of(tester.element(find.byType(StaffPaymentResultScreen)))!;

        // Header and status
        expect(find.text(l10n.paymentSuccessful), findsOneWidget);
        expect(find.text('BK-TEST-123'), findsOneWidget);
        expect(find.text(l10n.bookingStatusPaid), findsOneWidget);

        // Movie and seats
        expect(find.text('Lật Mặt 7'), findsOneWidget);
        expect(find.text('A1'), findsOneWidget);

        // Cash change
        expect(find.text(FormatUtils.formatCurrency(20000)), findsOneWidget);

        // Loyalty reward badge: +8000 points
        expect(find.text(l10n.posEarnedPointsSuccess(8000)), findsOneWidget);

        // Actions
        expect(find.text(l10n.posContinueSale), findsOneWidget);
        expect(find.text(l10n.posViewTickets), findsOneWidget);
      },
    );
  });
}
