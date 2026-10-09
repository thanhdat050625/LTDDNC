import 'package:cineplex_staff/features/ticket_sale/data/models/checkout_args.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/cubit/ticket_sale_cubit.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/cubit/ticket_sale_state.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/screens/checkout_screen.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/screens/concession_selection_screen.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/screens/seat_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class _FakeCinemaRepo implements CinemaManagementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeShowtimeRepo implements ShowtimeManagementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBookingRepo implements BookingManagementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const testMovie = MovieModel(
    id: 1,
    title: 'Dune: Part Two',
    genre: 'Sci-Fi',
    durationMinutes: 166,
    status: 'NOW_SHOWING',
  );

  const testRoom = RoomModel(
    id: 1,
    cinemaId: 1,
    name: 'Phòng 02',
    roomType: 'IMAX',
    totalSeats: 120,
    rows: 10,
    columns: 12,
    isCouple: false,
    status: 'ACTIVE',
  );

  final testShowtime = ShowtimeModel(
    id: 101,
    movieId: 1,
    roomId: 1,
    format: '2D',
    publicStartTime: DateTime.now().add(const Duration(hours: 2)),
    pricePerSeat: 85000,
    status: 'SCHEDULED',
    movie: testMovie,
    room: testRoom,
  );

  const seatA1 = SeatModel(
    seatId: 1,
    row: 'A',
    column: 1,
    label: 'A1',
    status: SeatStatus.available,
    isCouple: false,
  );

  const seatA2 = SeatModel(
    seatId: 2,
    row: 'A',
    column: 2,
    label: 'A2',
    status: SeatStatus.available,
    isCouple: false,
  );

  const seatBooked = SeatModel(
    seatId: 3,
    row: 'A',
    column: 3,
    label: 'A3',
    status: SeatStatus.booked,
    isCouple: false,
  );

  group('TicketSaleCubit Empirical State & Toggle Tests', () {
    test('toggleSeat correctly adds and removes seats', () {
      final cubit = TicketSaleCubit(
        _FakeCinemaRepo(),
        _FakeShowtimeRepo(),
        _FakeBookingRepo(),
      );

      // Seed initial loaded state
      cubit.emit(
        TicketSaleLoaded(
          cinemas: [],
          selectedShowtime: testShowtime,
          seats: [seatA1, seatA2],
          selectedSeats: [],
        ),
      );

      expect((cubit.state as TicketSaleLoaded).selectedSeats, isEmpty);

      // Toggle seat A1 -> Added
      cubit.toggleSeat(seatA1);
      final state1 = cubit.state as TicketSaleLoaded;
      expect(state1.selectedSeats.length, equals(1));
      expect(state1.selectedSeats.first.seatId, equals(seatA1.seatId));

      // Toggle seat A2 -> Added
      cubit.toggleSeat(seatA2);
      final state2 = cubit.state as TicketSaleLoaded;
      expect(state2.selectedSeats.length, equals(2));

      // Toggle seat A1 again -> Removed
      cubit.toggleSeat(seatA1);
      final state3 = cubit.state as TicketSaleLoaded;
      expect(state3.selectedSeats.length, equals(1));
      expect(state3.selectedSeats.first.seatId, equals(seatA2.seatId));

      // Toggle seat A2 again -> Empty
      cubit.toggleSeat(seatA2);
      final state4 = cubit.state as TicketSaleLoaded;
      expect(state4.selectedSeats, isEmpty);
    });
  });

  group('SeatSelectionScreen Flow & Dynamic Enabling Stress Tests', () {
    testWidgets(
      'Continue button dynamically enables on seat selection and disables when empty',
      (tester) async {
        final cubit = TicketSaleCubit(
          _FakeCinemaRepo(),
          _FakeShowtimeRepo(),
          _FakeBookingRepo(),
        );

        cubit.emit(
          TicketSaleLoaded(
            cinemas: [],
            selectedShowtime: testShowtime,
            seats: [seatA1, seatA2, seatBooked],
            selectedSeats: [],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('vi')],
            locale: const Locale('vi'),
            home: BlocProvider<TicketSaleCubit>.value(
              value: cubit,
              child: const SeatSelectionScreen(),
            ),
          ),
        );

        await tester.pump();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(SeatSelectionScreen)),
        )!;

        // 1. Verify initially Continue button is DISABLED
        final continueBtnFinder = find.widgetWithText(AppButton, l10n.continueBtn);
        expect(continueBtnFinder, findsOneWidget);
        AppButton btnWidget = tester.widget<AppButton>(continueBtnFinder);
        expect(btnWidget.onPressed, isNull);

        // 2. Tap available seat A1
        final seatA1Finder = find.text('1');
        expect(seatA1Finder, findsWidgets);
        await tester.tap(seatA1Finder.first);
        await tester.pump();

        // Verify cubit state has 1 selected seat
        expect((cubit.state as TicketSaleLoaded).selectedSeats.length, equals(1));

        // Verify Continue button is now ENABLED
        btnWidget = tester.widget<AppButton>(continueBtnFinder);
        expect(btnWidget.onPressed, isNotNull);

        // Verify Order Summary shows seat count 1 and seat label
        expect(find.text(l10n.seatCount(1)), findsOneWidget);
        expect(find.text('A1'), findsOneWidget);
        expect(find.text(FormatUtils.formatCurrency(85000)), findsWidgets);

        // 3. Tap seat A1 again to deselect
        await tester.tap(seatA1Finder.first);
        await tester.pump();

        // Verify cubit state is empty again
        expect((cubit.state as TicketSaleLoaded).selectedSeats, isEmpty);

        // Verify Continue button is dynamically DISABLED again
        btnWidget = tester.widget<AppButton>(continueBtnFinder);
        expect(btnWidget.onPressed, isNull);
      },
    );

    testWidgets(
      'Booked seat cannot be tapped or selected',
      (tester) async {
        final cubit = TicketSaleCubit(
          _FakeCinemaRepo(),
          _FakeShowtimeRepo(),
          _FakeBookingRepo(),
        );

        cubit.emit(
          TicketSaleLoaded(
            cinemas: [],
            selectedShowtime: testShowtime,
            seats: [seatBooked],
            selectedSeats: [],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('vi')],
            locale: const Locale('vi'),
            home: BlocProvider<TicketSaleCubit>.value(
              value: cubit,
              child: const SeatSelectionScreen(),
            ),
          ),
        );

        await tester.pump();

        // Tap booked seat '3'
        final seat3Finder = find.text('3');
        expect(seat3Finder, findsWidgets);
        await tester.tap(seat3Finder.first);
        await tester.pump();

        // Verify cubit selectedSeats remains empty
        expect((cubit.state as TicketSaleLoaded).selectedSeats, isEmpty);
      },
    );
  });

  group('CheckoutArgs & CheckoutScreen Dynamic Calculations Stress Tests', () {
    test('CheckoutArgs calculates edge-case totals accurately', () {
      // Empty args
      final emptyArgs = CheckoutArgs(
        showtime: testShowtime,
        selectedSeats: [],
      );
      expect(emptyArgs.ticketTotal, equals(0));
      expect(emptyArgs.concessionTotal, equals(0));
      expect(emptyArgs.grandTotal, equals(0));

      // With multiple concessions & points
      final fullArgs = CheckoutArgs(
        showtime: testShowtime,
        selectedSeats: [seatA1, seatA2], // 2 * 85000 = 170000
        concessions: [
          const SelectedConcession(name: 'Bắp', productId: 1, price: 55000, quantity: 2), // 110000
          const SelectedConcession(name: 'Nước', productId: 2, price: 45000, quantity: 1), // 45000
        ],
        pointsToUse: 25000,
      );

      expect(fullArgs.ticketTotal, equals(170000));
      expect(fullArgs.concessionTotal, equals(155000));
      // 170000 + 155000 - 25000 = 300000
      expect(fullArgs.grandTotal, equals(300000));
    });

    testWidgets('CheckoutScreen handles quick cash pills & calculates change', (
      tester,
    ) async {
      final args = CheckoutArgs(
        showtime: testShowtime,
        selectedSeats: [seatA1, seatA2],
        concessions: [
          const SelectedConcession(name: 'Bắp', productId: 1, price: 55000, quantity: 2),
        ],
      );
      // Total = 170000 + 110000 = 280000

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

      final l10n = AppLocalizations.of(
        tester.element(find.byType(CheckoutScreen)),
      )!;

      // Grand total should be 280.000 đ
      expect(find.text(FormatUtils.formatCurrency(280000)), findsWidgets);

      // Initially receivedAmount defaults to total (280000), so change is 0
      expect(find.text('${l10n.cashChange}: ${FormatUtils.formatCurrency(0)}'), findsOneWidget);

      // Tap '+50k' quick cash pill
      final plus50kFinder = find.text('+50k');
      expect(plus50kFinder, findsOneWidget);
      await tester.ensureVisible(plus50kFinder);
      await tester.pumpAndSettle();
      await tester.tap(plus50kFinder);
      await tester.pump();

      // Received amount is now 280000 + 50000 = 330000 -> change should be 50.000 đ
      expect(find.text('${l10n.cashChange}: ${FormatUtils.formatCurrency(50000)}'), findsOneWidget);

      // Tap 'Đủ tiền' quick cash pill
      final exactFinder = find.text('Đủ tiền');
      expect(exactFinder, findsOneWidget);
      await tester.ensureVisible(exactFinder);
      await tester.pumpAndSettle();
      await tester.tap(exactFinder);
      await tester.pump();

      // Change resets to 0
      expect(find.text('${l10n.cashChange}: ${FormatUtils.formatCurrency(0)}'), findsOneWidget);
    });

    testWidgets('CheckoutScreen survives null args gracefully without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: const CheckoutScreen(args: null),
        ),
      );

      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(CheckoutScreen)),
      )!;

      // Shows noData
      expect(find.text(l10n.noData), findsOneWidget);

      // Pay button should be disabled when args is null
      final payBtn = tester.widget<AppButton>(find.widgetWithText(AppButton, l10n.payNow));
      expect(payBtn.onPressed, isNull);
    });

    testWidgets('ConcessionSelectionScreen allows incrementing and decrementing concessions', (
      tester,
    ) async {
      final args = CheckoutArgs(
        showtime: testShowtime,
        selectedSeats: [seatA1],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('vi')],
          locale: const Locale('vi'),
          home: ConcessionSelectionScreen(args: args),
        ),
      );

      await tester.pump();

      // Find first '+' button for concessions (Popcorn)
      final plusIcons = find.byIcon(LucideIcons.plusCircle);
      expect(plusIcons, findsWidgets);

      // Tap '+' once
      await tester.tap(plusIcons.first);
      await tester.pump();

      // Quantity becomes 1
      expect(find.text('1'), findsWidgets);
      // Concession total row should show 55,000
      expect(find.text(FormatUtils.formatCurrency(55000)), findsWidgets);

      // Grand total should now be seat (85000) + concession (55000) = 140,000
      expect(find.text(FormatUtils.formatCurrency(140000)), findsWidgets);

      // Find first '-' button for concessions
      final minusIcons = find.byIcon(LucideIcons.minusCircle);
      await tester.tap(minusIcons.first);
      await tester.pump();

      // Grand total reverts to 85,000
      expect(find.text(FormatUtils.formatCurrency(85000)), findsWidgets);
    });

    testWidgets('CheckoutScreen toggles payment methods and hides cash calculator on non-cash', (
      tester,
    ) async {
      final args = CheckoutArgs(
        showtime: testShowtime,
        selectedSeats: [seatA1],
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

      final l10n = AppLocalizations.of(
        tester.element(find.byType(CheckoutScreen)),
      )!;

      // Initially CASH is selected, cash calculator elements exist
      expect(find.text('Đủ tiền'), findsOneWidget);

      // Tap MOMO payment method
      final momoFinder = find.text(l10n.momo);
      expect(momoFinder, findsOneWidget);
      await tester.ensureVisible(momoFinder);
      await tester.tap(momoFinder);
      await tester.pumpAndSettle();

      // Cash calculator elements should now be gone
      expect(find.text('Đủ tiền'), findsNothing);

      // Tap CASH payment method again
      final cashFinder = find.text(l10n.cash);
      expect(cashFinder, findsOneWidget);
      await tester.ensureVisible(cashFinder);
      await tester.tap(cashFinder);
      await tester.pumpAndSettle();

      // Cash calculator elements should be visible again
      expect(find.text('Đủ tiền'), findsOneWidget);
    });

    testWidgets('CheckoutScreen displays voucher section and handles initial voucher & removal', (
      tester,
    ) async {
      final args = CheckoutArgs(
        showtime: testShowtime,
        selectedSeats: [seatA1, seatA2], // 170000
        promotionCode: 'GIAM20K',
        discountAmount: 20000,
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

      final l10n = AppLocalizations.of(
        tester.element(find.byType(CheckoutScreen)),
      )!;

      // Applied promo code badge
      expect(find.text('GIAM20K'), findsOneWidget);
      expect(find.text(l10n.promotionApplied), findsOneWidget);
      expect(find.text('-${FormatUtils.formatCurrency(20000)}'), findsWidgets);

      // Grand total should be 170000 - 20000 = 150000
      expect(find.text(FormatUtils.formatCurrency(150000)), findsWidgets);

      // Tap remove promotion button
      final removeBtnFinder = find.text(l10n.removePromotion);
      expect(removeBtnFinder, findsOneWidget);
      await tester.tap(removeBtnFinder);
      await tester.pump();

      // Voucher removed, grand total reverts to 170000
      expect(find.text(FormatUtils.formatCurrency(170000)), findsWidgets);
      // Input field should now appear
      expect(find.widgetWithText(AppButton, l10n.applyPromotion), findsOneWidget);
    });
  });
}

