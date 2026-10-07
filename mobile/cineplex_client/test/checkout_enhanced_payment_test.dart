import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/booking/data/repositories/booking_repository.dart';
import 'package:cineplex_client/features/payment/presentation/screens/checkout_screen.dart';
import 'package:cineplex_client/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:cineplex_client/features/payment/data/repositories/payment_repository.dart';
import 'package:cineplex_client/features/payment/data/models/payment_model.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}
class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(CreateBookingDto(showtimeId: 0, seatIds: const []));
  });

  late MockPaymentRepository repo;

  const mockData = CheckoutPrepareModel(
    bookingId: '101',
    bookingCode: 'CPX-TEST-101',
    totalAmount: 180000,
    discountAmount: 20000,
    pointsUsed: 10000,
    secondsRemaining: 300,
    promotionCode: 'SALE20',
    loyaltyPoints: 50000,
    ticketTotal: 150000,
    concessionTotal: 60000,
    estimatedPointsEarned: 18000,
    seats: [
      CheckoutSeatItem(id: 1, row: 'E', column: 5),
      CheckoutSeatItem(id: 2, row: 'E', column: 6),
    ],
    concessions: [
      CheckoutConcessionItem(
        productId: 1,
        name: 'Combo Solo Bắp Nước',
        quantity: 1,
        unitPrice: 60000,
        subtotal: 60000,
      ),
    ],
  );

  setUp(() {
    repo = MockPaymentRepository();
    when(() => repo.prepareCheckout('101')).thenAnswer((_) async => mockData);
    when(() => repo.getActivePromotions()).thenAnswer((_) async => [
      PromotionModel(
        id: 1,
        code: 'PROMO10',
        description: 'Giảm 10% tổng đơn',
        discountType: 'PERCENTAGE',
        discountValue: 10,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        usedCount: 0,
        isActive: true,
      ),
    ]);
  });

  Widget buildHarness({required PaymentCubit cubit}) {
    return RepositoryProvider<PaymentRepository>.value(
      value: repo,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('vi')],
        locale: const Locale('vi'),
        home: BlocProvider<PaymentCubit>.value(
          value: cubit,
          child: const CheckoutScreen(bookingId: '101'),
        ),
      ),
    );
  }

  group('CheckoutScreen Enhanced Payment, Voucher & Loyalty Tests', () {
    testWidgets('1. Only MoMo and VNPay methods are displayed, no ZaloPay or Card', (tester) async {
      final cubit = PaymentCubit(repo);

      await tester.pumpWidget(buildHarness(cubit: cubit));
      await tester.pumpAndSettle();

      // Verify MOMO and VNPAY exist
      expect(find.text('Ví MoMo'), findsOneWidget);
      expect(find.text('Cổng VNPAY'), findsOneWidget);

      // Verify ZaloPay and Card do NOT exist
      expect(find.text('Ví ZaloPay'), findsNothing);
      expect(find.text('Thẻ ATM / Thẻ quốc tế'), findsNothing);
    });

    testWidgets('2. Displays itemized goods (Seats, Concessions) and financial breakdown', (tester) async {
      final cubit = PaymentCubit(repo);

      await tester.pumpWidget(buildHarness(cubit: cubit));
      await tester.pumpAndSettle();

      // Check seats itemized
      expect(find.textContaining('E5, E6'), findsOneWidget);

      // Check concession itemized
      expect(find.textContaining('Combo Solo Bắp Nước'), findsOneWidget);

      // Check discount rows
      expect(find.text('Giảm giá'), findsOneWidget);
      expect(find.text('Giảm giá từ điểm'), findsWidgets);

      // Check loyalty points earn badge
      expect(find.textContaining('Tích lũy +'), findsOneWidget);
    });

    testWidgets('3. Loyalty points toggle triggers remove/apply calls correctly', (tester) async {
      when(() => repo.removeLoyaltyPoints('101')).thenAnswer((_) async => {
        'totalAmount': 190000,
        'discountAmount': 20000,
        'pointsUsed': 0,
      });

      final cubit = PaymentCubit(repo);

      await tester.pumpWidget(buildHarness(cubit: cubit));
      await tester.pumpAndSettle();

      // Switch is initially ON because pointsUsed > 0 (10000)
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Toggle switch OFF
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      verify(() => repo.removeLoyaltyPoints('101')).called(1);
    });

    testWidgets('4. In draft mode (bookingId: 0), clicking payNow creates booking via createBooking with full info and triggers checkout', (tester) async {
      final mockBookingRepo = MockBookingRepository();
      when(() => repo.prepareCheckoutDraft(
            showtimeId: 202,
            seatIds: [1, 2],
            concessions: any(named: 'concessions'),
          )).thenAnswer((_) async => const CheckoutPrepareModel(
            bookingId: '0',
            bookingCode: 'DRAFT',
            totalAmount: 180000,
            discountAmount: 0,
            pointsUsed: 0,
            secondsRemaining: 300,
            loyaltyPoints: 30000,
            ticketTotal: 150000,
            concessionTotal: 30000,
            estimatedPointsEarned: 18000,
            seats: [
              CheckoutSeatItem(id: 1, row: 'A', column: 1),
              CheckoutSeatItem(id: 2, row: 'A', column: 2),
            ],
            concessions: [],
          ));

      when(() => mockBookingRepo.createBooking(any())).thenAnswer((_) async => BookingModel(
            id: 999,
            bookingCode: 'BK-999',
            showtimeId: 202,
            totalAmount: 180000,
            discountAmount: 0,
            pointsUsed: 0,
            status: 'PENDING',
            expiredAt: DateTime.now().add(const Duration(minutes: 5)),
          ));

      when(() => repo.checkout('999', any())).thenAnswer((_) async => const PaymentResponseModel(
            bookingId: '999',
            payUrl: 'https://payment.example.com/pay',
            paymentRequired: true,
          ));

      const draftArgs = CheckoutScreenArgs(
        showtimeId: 202,
        seatIds: [1, 2],
        seatPrice: 150000,
        concessions: [],
      );

      final cubit = PaymentCubit(repo, mockBookingRepo);

      final router = GoRouter(
        initialLocation: '/checkout',
        routes: [
          GoRoute(
            path: '/checkout',
            builder: (_, __) => BlocProvider<PaymentCubit>.value(
              value: cubit,
              child: const CheckoutScreen(bookingId: '0', args: draftArgs),
            ),
          ),
          GoRoute(
            path: '/payment-webview',
            builder: (_, __) => const SizedBox(),
          ),
        ],
      );

      await tester.pumpWidget(
        RepositoryProvider<PaymentRepository>.value(
          value: repo,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('vi')],
            locale: const Locale('vi'),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DRAFT'), findsOneWidget);
      expect(find.text('Thanh toán ngay'), findsOneWidget);

      await tester.ensureVisible(find.text('Thanh toán ngay'));
      await tester.tap(find.text('Thanh toán ngay'));
      await tester.pumpAndSettle();

      verify(() => mockBookingRepo.createBooking(any(that: isA<CreateBookingDto>().having(
            (dto) => dto.showtimeId,
            'showtimeId',
            202,
          )))).called(1);
      verify(() => repo.checkout('999', 'MOMO')).called(1);
    });
  });
}
