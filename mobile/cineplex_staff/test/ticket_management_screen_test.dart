import 'package:cineplex_staff/features/tickets/presentation/cubit/ticket_management_cubit.dart';
import 'package:cineplex_staff/features/tickets/presentation/screens/ticket_management_screen.dart';
import 'package:cineplex_staff/features/tickets/presentation/widgets/booking_ticket_card.dart';
import 'package:cineplex_staff/features/tickets/presentation/widgets/ticket_price_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class _MockBookingManagementRepository implements BookingManagementRepository {
  final List<BookingDetailModel> mockBookings;
  final List<TicketPriceModel> mockPrices;

  _MockBookingManagementRepository({
    required this.mockBookings,
    required this.mockPrices,
  });

  @override
  Future<List<BookingDetailModel>> getAllBookings({
    int page = 1,
    int pageSize = 20,
  }) async {
    return mockBookings;
  }

  @override
  Future<List<TicketPriceModel>> getTicketPrices() async {
    return mockPrices;
  }

  @override
  Future<void> updateTicketPrice(int id, num price) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final testTickets = [
    const TicketModel(
      id: '1',
      bookingId: '101',
      seatId: 's1',
      seatLabel: 'D5',
      qrCode: 'TKT-101-D5',
      price: 90000,
      isCheckedIn: true,
      status: 'ACTIVE',
    ),
    const TicketModel(
      id: '2',
      bookingId: '101',
      seatId: 's2',
      seatLabel: 'D6',
      qrCode: 'TKT-101-D6',
      price: 90000,
      isCheckedIn: false,
      status: 'ACTIVE',
    ),
  ];

  final testBookings = [
    BookingDetailModel(
      id: '101',
      bookingCode: 'BK-2026-001',
      totalAmount: 180000,
      status: 'CONFIRMED',
      movieTitle: 'Mai',
      cinemaName: 'Cineplex Thủ Đức',
      roomName: 'Rạp 01',
      startTime: '2026-10-05T19:00:00.000Z',
      customerName: 'Nguyễn Văn A',
      customerPhone: '0901234567',
      paymentMethod: 'VNPAY',
      tickets: testTickets,
    ),
    const BookingDetailModel(
      id: '102',
      bookingCode: 'BK-2026-002',
      totalAmount: 90000,
      status: 'PENDING',
      movieTitle: 'Lật Mặt 7',
      cinemaName: 'Cineplex Thủ Đức',
      roomName: 'Rạp 02',
      startTime: '2026-10-05T20:30:00.000Z',
      customerName: 'Trần Thị B',
      tickets: [],
    ),
  ];

  final testPrices = [
    const TicketPriceModel(
      id: 1,
      roomType: 'STANDARD',
      dayType: 'WEEKDAY',
      price: 80000,
    ),
    const TicketPriceModel(
      id: 2,
      roomType: 'STANDARD',
      dayType: 'WEEKEND',
      price: 95000,
    ),
    const TicketPriceModel(
      id: 3,
      roomType: 'IMAX',
      dayType: 'WEEKEND',
      price: 150000,
    ),
  ];

  Widget buildTestWidget({ThemeData? theme}) {
    final repo = _MockBookingManagementRepository(
      mockBookings: testBookings,
      mockPrices: testPrices,
    );
    final cubit = TicketManagementCubit(repo);

    return MaterialApp(
      theme: theme ?? AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('vi')],
      locale: const Locale('vi'),
      home: BlocProvider<TicketManagementCubit>.value(
        value: cubit,
        child: const TicketManagementScreen(),
      ),
    );
  }

  testWidgets(
    'TicketManagementScreen renders tabs, bookings, and bottom sheet detail',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(TicketManagementScreen)),
      )!;

      // Verify AppBar Title & Actions
      expect(find.text(l10n.manageTickets), findsOneWidget);

      // Verify Tab Headers
      expect(find.text(l10n.ticketBookingList), findsOneWidget);
      expect(find.text(l10n.ticketPriceConfig), findsOneWidget);

      // Verify Bookings list
      expect(find.byType(BookingTicketCard), findsNWidgets(2));
      expect(find.text('BK-2026-001'), findsOneWidget);
      expect(find.text('BK-2026-002'), findsOneWidget);
      expect(find.text('Mai'), findsOneWidget);

      // Tap on first booking card to open bottom sheet
      await tester.tap(find.text('BK-2026-001'));
      await tester.pumpAndSettle();

      // Verify Bottom Sheet contents
      expect(find.text(l10n.ticketDetailTitle), findsOneWidget);
      expect(find.text('TKT-101-D5'), findsOneWidget);
      expect(find.text('TKT-101-D6'), findsOneWidget);
      expect(find.text(l10n.ticketCheckedInStatus), findsOneWidget);
      expect(find.text(l10n.ticketNotCheckedInStatus), findsOneWidget);

      // Close bottom sheet
      await tester.tap(find.byIcon(LucideIcons.x).first);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'TicketManagementScreen switches to Ticket Price Config tab and renders price items',
    (tester) async {
      await tester.pumpWidget(buildTestWidget(theme: AppTheme.lightTheme));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(TicketManagementScreen)),
      )!;

      // Tap on Price Config tab
      await tester.tap(find.text(l10n.ticketPriceConfig));
      await tester.pumpAndSettle();

      // Verify TicketPriceTable is rendered
      expect(find.byType(TicketPriceTable), findsOneWidget);
      expect(find.text('STANDARD'), findsNWidgets(2));
      expect(find.text('IMAX'), findsOneWidget);
      expect(find.text(l10n.ticketPriceWeekday), findsOneWidget);
      expect(find.text(l10n.ticketPriceWeekend), findsNWidgets(2));
    },
  );
}
