import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cineplex_client/features/payment/data/models/payment_model.dart';
import 'package:cineplex_client/features/payment/data/repositories/payment_repository.dart';
import 'package:cineplex_client/features/payment/presentation/cubit/payment_cubit.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late MockPaymentRepository repository;

  setUp(() {
    repository = MockPaymentRepository();
  });

  group('PaymentCubit Retry & Expiry Tests (A5.1 / E5.1 / E6.1)', () {
    test('initial state is PaymentInitial', () {
      final cubit = PaymentCubit(repository);
      expect(cubit.state, equals(PaymentInitial()));
      cubit.close();
    });

    blocTest<PaymentCubit, PaymentState>(
      '1. Payment failed but hold still valid allows retry (canRetry: true, isExpired: false)',
      build: () {
        when(() => repository.getPaymentStatus('123')).thenAnswer((_) async => const PaymentStatusModel(
          bookingId: '123',
          bookingCode: 'BK-123',
          status: 'FAILED',
          canRetry: true,
          isExpired: false,
          showtimeId: 101,
        ));
        return PaymentCubit(repository);
      },
      act: (cubit) => cubit.checkStatus('123'),
      expect: () => [
        isA<PaymentPolling>(),
        isA<PaymentFailed>()
            .having((s) => s.message, 'message', 'Thanh toán thất bại')
            .having((s) => s.status?.canRetry, 'canRetry', true)
            .having((s) => s.status?.isExpired, 'isExpired', false)
            .having((s) => s.status?.showtimeId, 'showtimeId', 101),
      ],
      verify: (_) {
        verify(() => repository.getPaymentStatus('123')).called(1);
      },
    );

    blocTest<PaymentCubit, PaymentState>(
      '2. Payment failed and hold expired flags for return to seat map (isExpired: true)',
      build: () {
        when(() => repository.getPaymentStatus('123')).thenAnswer((_) async => const PaymentStatusModel(
          bookingId: '123',
          bookingCode: 'BK-123',
          status: 'EXPIRED',
          canRetry: false,
          isExpired: true,
          showtimeId: 101,
        ));
        return PaymentCubit(repository);
      },
      act: (cubit) => cubit.checkStatus('123'),
      expect: () => [
        isA<PaymentPolling>(),
        isA<PaymentFailed>()
            .having((s) => s.message, 'message', 'Đơn đặt vé đã hết thời gian giữ chỗ')
            .having((s) => s.status?.canRetry, 'canRetry', false)
            .having((s) => s.status?.isExpired, 'isExpired', true)
            .having((s) => s.status?.showtimeId, 'showtimeId', 101),
      ],
      verify: (_) {
        verify(() => repository.getPaymentStatus('123')).called(1);
      },
    );

    blocTest<PaymentCubit, PaymentState>(
      '3. Payment succeeded emits PaymentSuccess',
      build: () {
        when(() => repository.getPaymentStatus('123')).thenAnswer((_) async => const PaymentStatusModel(
          bookingId: '123',
          bookingCode: 'BK-123',
          status: 'PAID',
          canRetry: false,
          isExpired: false,
          showtimeId: 101,
        ));
        return PaymentCubit(repository);
      },
      act: (cubit) => cubit.checkStatus('123'),
      expect: () => [
        isA<PaymentPolling>(),
        isA<PaymentSuccess>()
            .having((s) => s.status.status, 'status', 'PAID'),
      ],
      verify: (_) {
        verify(() => repository.getPaymentStatus('123')).called(1);
      },
    );
  });
}
