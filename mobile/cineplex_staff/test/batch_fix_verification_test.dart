import 'package:cineplex_staff/features/ticket_sale/data/models/checkout_args.dart';
import 'package:cineplex_staff/features/ticket_sale/presentation/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_shared/mobile_shared.dart';

void main() {
  group('Batch Fix Verification Tests - Loyalty & MoMo', () {
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
        title: 'Dune: Part Two',
        genre: 'Sci-Fi',
        durationMinutes: 166,
        status: 'NOW_SHOWING',
      ),
      room: const RoomModel(
        id: 1,
        cinemaId: 1,
        name: 'Phòng 02',
        roomType: 'STANDARD',
        totalSeats: 100,
        rows: 10,
        columns: 10,
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
    ];

    const customer = UserModel(
      id: 42,
      fullName: 'Nguyen Van A',
      email: 'nguyenvana@gmail.com',
      role: 'CUSTOMER',
      status: 'ACTIVE',
      loyaltyPoints: 20000,
    );

    void setScreenSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('TC-LOY-001: Customer có 20.000 điểm -> UI hiển thị đúng 20.000 điểm', (
      tester,
    ) async {
      setScreenSize(tester);

      final args = CheckoutArgs(
        showtime: showtime,
        selectedSeats: seats,
        customer: customer,
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
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(CheckoutScreen)))!;

      // Verify real customer name, points badge, and loyalty switch toggle
      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(find.text('20.000 ${l10n.pointsSuffix}'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('TC-LOY-002: Bật Switch dùng điểm -> tự động tính toán tối đa 20% (20.000 điểm)', (
      tester,
    ) async {
      setScreenSize(tester);

      final args = CheckoutArgs(
        showtime: showtime,
        selectedSeats: seats, // ticketTotal = 100,000. 20% limit = 20,000
        customer: customer,
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
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(CheckoutScreen)))!;

      // Tap Switch to enable points auto-calculation
      final switchWidget = find.byType(Switch);
      expect(switchWidget, findsOneWidget);
      await tester.ensureVisible(switchWidget);
      await tester.tap(switchWidget);
      await tester.pumpAndSettle();

      // Verify active badge: "Đang sử dụng 20.000 điểm" (auto capped at 20%)
      expect(find.text(l10n.posUsingPointsBadge('20.000')), findsOneWidget);
      // Verify preview values
      expect(find.text('0 ${l10n.pointsSuffix}'), findsOneWidget); // remaining
      expect(find.text(l10n.discountPointsTitle), findsOneWidget); // discount row in breakdown
      // Total amount reduced by 20,000 (100,000 - 20,000 = 80,000 đ)
      expect(find.text(FormatUtils.formatCurrency(80000)), findsWidgets);
    });

    testWidgets('TC-LOY-003: Bấm Hủy sử dụng điểm -> điểm = 0, discount = 0, tổng tiền quay về giá trị ban đầu', (
      tester,
    ) async {
      setScreenSize(tester);

      final args = CheckoutArgs(
        showtime: showtime,
        selectedSeats: seats,
        customer: customer,
        pointsToUse: 5000,
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
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(CheckoutScreen)))!;

      // Active badge exists
      expect(find.text(l10n.posUsingPointsBadge('5.000')), findsOneWidget);
      expect(find.text(FormatUtils.formatCurrency(95000)), findsWidgets);

      // Tap "Hủy" button
      final cancelPointsBtn = find.text(l10n.posCancelPoints);
      expect(cancelPointsBtn, findsOneWidget);
      await tester.ensureVisible(cancelPointsBtn);
      await tester.tap(cancelPointsBtn);
      await tester.pumpAndSettle();

      // Badge disappears
      expect(find.text(l10n.posUsingPointsBadge('5.000')), findsNothing);
      // Total amount returns to 100,000 đ
      expect(find.text(FormatUtils.formatCurrency(100000)), findsWidgets);
    });

    testWidgets('TC-LOY-004: Khách nhiều điểm -> Tự động giới hạn tối đa 20% tổng đơn', (
      tester,
    ) async {
      setScreenSize(tester);

      final richCustomer = UserModel(
        id: 99,
        fullName: 'Rich Customer',
        email: 'rich@gmail.com',
        role: 'CUSTOMER',
        status: 'ACTIVE',
        loyaltyPoints: 100000, // Very high points
      );

      final args = CheckoutArgs(
        showtime: showtime,
        selectedSeats: seats, // ticketTotal = 100,000 -> 20% max = 20,000
        customer: richCustomer,
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
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(CheckoutScreen)))!;

      // Tap Switch
      final switchWidget = find.byType(Switch);
      await tester.ensureVisible(switchWidget);
      await tester.tap(switchWidget);
      await tester.pumpAndSettle();

      // Auto-calculated up to max 20,000 (not 100,000)
      expect(find.text(l10n.posUsingPointsBadge('20.000')), findsOneWidget);
      // Total: 80,000đ
      expect(find.text(FormatUtils.formatCurrency(80000)), findsWidgets);
    });

    testWidgets('TC-MOMO-001: Chọn MoMo -> Phương thức chuyển sang MoMo, không tự động coi là SUCCESS', (
      tester,
    ) async {
      setScreenSize(tester);

      final args = CheckoutArgs(
        showtime: showtime,
        selectedSeats: seats,
        customer: customer,
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
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(CheckoutScreen)))!;

      // Tap MoMo method
      final momoCard = find.text(l10n.momo);
      expect(momoCard, findsOneWidget);
      await tester.ensureVisible(momoCard);
      await tester.tap(momoCard);
      await tester.pumpAndSettle();

      // Cash calculator is hidden
      expect(find.text(l10n.cashReceived), findsNothing);

      // Verify payment success dialog is NOT shown
      expect(find.text(l10n.paymentSuccess), findsNothing);
      expect(find.text(l10n.payNow), findsOneWidget);
    });
  });
}
