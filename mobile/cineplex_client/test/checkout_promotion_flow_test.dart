import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/payment/data/models/payment_model.dart';
import 'package:cineplex_client/features/payment/data/repositories/payment_repository.dart';
import 'package:cineplex_client/features/payment/presentation/cubit/payment_cubit.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockPaymentRepository repository;

  const initialCheckoutData = CheckoutPrepareModel(
    bookingId: '123',
    bookingCode: 'BK-123',
    totalAmount: 100000,
    discountAmount: 0,
    pointsUsed: 0,
    secondsRemaining: 300,
  );

  setUp(() {
    repository = MockPaymentRepository();
  });

  group('Checkout Promotion Flow Tests (BUG-15)', () {
    test('initial state is PaymentInitial', () {
      final cubit = PaymentCubit(repository);
      expect(cubit.state, equals(PaymentInitial()));
      cubit.close();
    });

    blocTest<PaymentCubit, PaymentState>(
      '1. Apply valid promotion successfully updates totalAmount, discountAmount, and promoCode',
      build: () {
        when(() => repository.applyPromotion('123', 'PROMO20')).thenAnswer((_) async => {
          'totalAmount': 80000,
          'discountAmount': 20000,
          'promotionCode': 'PROMO20',
        });
        return PaymentCubit(repository);
      },
      seed: () => const CheckoutPrepared(initialCheckoutData),
      act: (cubit) => cubit.applyPromotion('123', 'PROMO20'),
      expect: () => [
        isA<CheckoutPrepared>()
            .having((s) => s.data.totalAmount, 'totalAmount', 80000)
            .having((s) => s.data.discountAmount, 'discountAmount', 20000)
            .having((s) => s.appliedPromoCode, 'appliedPromoCode', 'PROMO20'),
      ],
      verify: (_) {
        verify(() => repository.applyPromotion('123', 'PROMO20')).called(1);
      },
    );

    blocTest<PaymentCubit, PaymentState>(
      '2. Apply invalid promotion (PROMOTION_NOT_FOUND) emits localized error message and keeps basket intact',
      build: () {
        when(() => repository.applyPromotion('123', 'INVALID_CODE')).thenThrow(
          ServerException('Not found', code: 'PROMOTION_NOT_FOUND'),
        );
        return PaymentCubit(repository);
      },
      seed: () => const CheckoutPrepared(initialCheckoutData),
      act: (cubit) => cubit.applyPromotion('123', 'INVALID_CODE'),
      expect: () => [
        isA<PaymentFailed>().having((s) => s.message, 'message', 'Mã khuyến mãi không tồn tại'),
        isA<CheckoutPrepared>().having((s) => s.data, 'original data preserved', initialCheckoutData),
      ],
      verify: (_) {
        verify(() => repository.applyPromotion('123', 'INVALID_CODE')).called(1);
      },
    );

    blocTest<PaymentCubit, PaymentState>(
      '3. Remove promotion calls DELETE endpoint and resets price and discount back to original',
      build: () {
        when(() => repository.removePromotion('123')).thenAnswer((_) async => {
          'totalAmount': 100000,
          'discountAmount': 0,
        });
        return PaymentCubit(repository);
      },
      seed: () => CheckoutPrepared(
        initialCheckoutData.copyWith(
          totalAmount: 80000,
          discountAmount: 20000,
          promotionCode: 'PROMO20',
        ),
        appliedPromoCode: 'PROMO20',
      ),
      act: (cubit) => cubit.removePromotion('123'),
      expect: () => [
        isA<CheckoutPrepared>()
            .having((s) => s.data.totalAmount, 'totalAmount', 100000)
            .having((s) => s.data.discountAmount, 'discountAmount', 0)
            .having((s) => s.appliedPromoCode, 'appliedPromoCode', isNull),
      ],
      verify: (_) {
        verify(() => repository.removePromotion('123')).called(1);
      },
    );
  });
}
