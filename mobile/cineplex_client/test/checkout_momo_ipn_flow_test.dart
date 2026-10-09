import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/payment/data/models/payment_model.dart';
import 'package:cineplex_client/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:cineplex_client/features/payment/presentation/screens/checkout_screen.dart';
import 'package:cineplex_client/features/payment/data/repositories/payment_repository.dart';
import 'package:cineplex_client/features/booking/data/repositories/booking_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}
class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  group('Payment Model JSON Parsing Safety', () {
    test('PaymentResponseModel safely parses int bookingId from backend without type error', () {
      final jsonWithInt = {
        'bookingId': 789,
        'payUrl': 'https://test-payment.momo.vn/v2/gateway/pay?token=xyz',
        'paymentRequired': true,
      };

      final model = PaymentResponseModel.fromJson(jsonWithInt);
      expect(model.bookingId, '789');
      expect(model.payUrl, 'https://test-payment.momo.vn/v2/gateway/pay?token=xyz');
      expect(model.paymentRequired, isTrue);
    });

    test('PaymentStatusModel safely parses int bookingId and numeric fields from backend', () {
      final jsonWithInt = {
        'bookingId': 789,
        'bookingCode': 'BK-789',
        'status': 'PAID',
        'paymentMethod': 'MOMO',
        'canRetry': false,
        'isExpired': false,
        'showtimeId': 101,
      };

      final model = PaymentStatusModel.fromJson(jsonWithInt);
      expect(model.bookingId, '789');
      expect(model.bookingCode, 'BK-789');
      expect(model.status, 'PAID');
      expect(model.paymentMethod, 'MOMO');
      expect(model.showtimeId, 101);
    });
  });

  group('Checkout MoMo & Waiting Dialog Flow Test', () {
    late MockPaymentRepository paymentRepo;
    late MockBookingRepository bookingRepo;

    setUp(() {
      paymentRepo = MockPaymentRepository();
      bookingRepo = MockBookingRepository();
    });

    testWidgets('Emitting PaymentUrlReady displays MoMo waiting dialog with check status button and handles PAID result', (tester) async {
      when(() => paymentRepo.prepareCheckout('789')).thenAnswer((_) async => const CheckoutPrepareModel(
        bookingId: '789',
        bookingCode: 'BK-789',
        totalAmount: 150000,
        discountAmount: 0,
        ticketTotal: 150000,
        concessionTotal: 0,
      ));
      when(() => paymentRepo.getActivePromotions()).thenAnswer((_) async => []);
      when(() => paymentRepo.getPaymentStatus('789')).thenAnswer((_) async => const PaymentStatusModel(
        bookingId: '789',
        bookingCode: 'BK-789',
        status: 'PAID',
        paymentMethod: 'MOMO',
      ));

      final cubit = PaymentCubit(paymentRepo, bookingRepo);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('vi'),
          home: BlocProvider<PaymentCubit>.value(
            value: cubit,
            child: const CheckoutScreen(bookingId: '789'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select MoMo method explicitly since VNPay is default
      await tester.tap(find.text('Ví MoMo'));
      await tester.pumpAndSettle();

      // Emit PaymentUrlReady (simulating user clicking payNow)
      cubit.emit(const PaymentUrlReady(
        'https://test-payment.momo.vn/pay',
        bookingId: '789',
        bookingCode: 'BK-789',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify that the waiting dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('BK-789', skipOffstage: false), findsWidgets);
      expect(find.text('Kiểm tra thanh toán'), findsOneWidget);
      expect(find.text('Mở cổng thanh toán MoMo'), findsOneWidget);

      // Tap "Kiểm tra thanh toán" button
      await tester.tap(find.text('Kiểm tra thanh toán'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify repository was checked
      verify(() => paymentRepo.getPaymentStatus('789')).called(greaterThanOrEqualTo(1));
    });
  });
}
