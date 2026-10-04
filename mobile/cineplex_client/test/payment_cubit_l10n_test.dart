import 'package:flutter_test/flutter_test.dart';
import 'package:cineplex_client/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:cineplex_client/features/payment/data/repositories/payment_repository.dart';
import 'package:cineplex_client/features/payment/data/models/payment_model.dart';

class FakePaymentRepository implements PaymentRepository {
  final String statusToReturn;
  FakePaymentRepository(this.statusToReturn);

  @override
  Future<PaymentStatusModel> getPaymentStatus(String bookingId) async {
    return PaymentStatusModel(
      bookingId: bookingId,
      bookingCode: 'BK123',
      status: statusToReturn,
    );
  }

  @override
  Future<CheckoutPrepareModel> prepareCheckout(String bookingId) async => throw UnimplementedError();

  @override
  Future<PaymentResponseModel> checkout(String bookingId, String method) async => throw UnimplementedError();

  @override
  Future<dynamic> checkPromotion(String code, {String? movieId}) async => throw UnimplementedError();
}

void main() {
  group('PaymentCubit L10n & State String Integrity', () {
    test('PaymentCubit emits localized Vietnamese error string "Thanh toán thất bại" on FAILED status', () async {
      final repo = FakePaymentRepository('FAILED');
      final cubit = PaymentCubit(repo);

      await cubit.checkStatus('booking-123');

      expect(cubit.state, isA<PaymentFailed>());
      final failedState = cubit.state as PaymentFailed;

      expect(failedState.message, equals('Thanh toán thất bại'));
    });

    test('PaymentCubit emits localized Vietnamese string "Trạng thái thanh toán: ..." on non-success status', () async {
      final repo = FakePaymentRepository('TIMEOUT');
      final cubit = PaymentCubit(repo);

      await cubit.checkStatus('booking-123');

      expect(cubit.state, isA<PaymentFailed>());
      final failedState = cubit.state as PaymentFailed;

      expect(failedState.message, equals('Trạng thái thanh toán: TIMEOUT'));
    });
  });
}
