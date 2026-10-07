import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class CheckoutPrepared extends PaymentState {
  final CheckoutPrepareModel data;
  final String? appliedPromoCode;
  const CheckoutPrepared(this.data, {this.appliedPromoCode});
  @override
  List<Object?> get props => [data, appliedPromoCode];
}

class PaymentUrlReady extends PaymentState {
  final String payUrl;
  const PaymentUrlReady(this.payUrl);
  @override
  List<Object?> get props => [payUrl];
}

class PaymentSuccess extends PaymentState {
  final PaymentStatusModel status;
  const PaymentSuccess(this.status);
  @override
  List<Object?> get props => [status];
}

class PaymentFailed extends PaymentState {
  final String message;
  final PaymentStatusModel? status;
  const PaymentFailed(this.message, {this.status});
  @override
  List<Object?> get props => [message, status];
}

class PaymentPolling extends PaymentState {}

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repository;

  PaymentCubit(this.repository) : super(PaymentInitial());

  Future<void> prepareCheckout(String bookingId) async {
    emit(PaymentLoading());
    try {
      final data = await repository.prepareCheckout(bookingId);
      emit(CheckoutPrepared(data, appliedPromoCode: data.promotionCode));
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }

  Future<void> checkout(String bookingId, String method) async {
    emit(PaymentLoading());
    try {
      final data = await repository.checkout(bookingId, method);
      if (data.paymentRequired && data.payUrl.isNotEmpty) {
        emit(PaymentUrlReady(data.payUrl));
      } else {
        checkStatus(bookingId);
      }
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }

  Future<void> checkStatus(String bookingId) async {
    emit(PaymentPolling());
    try {
      final status = await repository.getPaymentStatus(bookingId);
      if (status.status == 'SUCCESS' || status.status == 'PAID') {
        emit(PaymentSuccess(status));
      } else if (status.status == 'FAILED' || status.isExpired) {
        final msg = status.isExpired
            ? 'Đơn đặt vé đã hết thời gian giữ chỗ'
            : 'Thanh toán thất bại';
        emit(PaymentFailed(msg, status: status));
      } else {
        emit(PaymentFailed('Trạng thái thanh toán: ${status.status}', status: status));
      }
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }

  Future<void> applyPromotion(String bookingId, String code) async {
    if (state is CheckoutPrepared) {
      final current = (state as CheckoutPrepared).data;
      try {
        final res = await repository.applyPromotion(bookingId, code);
        final totalAmount = (res['totalAmount'] as num?) ?? current.totalAmount;
        final discountAmount = (res['discountAmount'] as num?) ?? current.discountAmount;
        final promoCode = (res['promotionCode'] as String?) ?? code;
        final updated = current.copyWith(
          totalAmount: totalAmount,
          discountAmount: discountAmount,
          promotionCode: promoCode,
        );
        emit(CheckoutPrepared(updated, appliedPromoCode: promoCode));
      } catch (e) {
        final errorMsg = _mapPromotionError(e);
        emit(PaymentFailed(errorMsg));
        emit(CheckoutPrepared(current));
      }
    }
  }

  Future<void> removePromotion(String bookingId) async {
    if (state is CheckoutPrepared) {
      final current = (state as CheckoutPrepared).data;
      try {
        final res = await repository.removePromotion(bookingId);
        final totalAmount = (res['totalAmount'] as num?) ?? (current.totalAmount + current.discountAmount);
        final updated = current.copyWith(
          totalAmount: totalAmount,
          discountAmount: 0,
        );
        emit(CheckoutPrepared(updated, appliedPromoCode: null));
      } catch (e) {
        emit(PaymentFailed(e.toString()));
        emit(CheckoutPrepared(current));
      }
    }
  }

  String _mapPromotionError(Object e) {
    if (e is ServerException) {
      switch (e.code) {
        case 'PROMOTION_NOT_FOUND':
          return 'Mã khuyến mãi không tồn tại';
        case 'PROMOTION_INACTIVE':
          return 'Mã khuyến mãi đã ngưng hoạt động';
        case 'PROMOTION_EXPIRED':
          return 'Mã khuyến mãi đã hết hạn hoặc chưa bắt đầu';
        case 'PROMOTION_MAX_USAGE':
          return 'Mã khuyến mãi đã hết lượt sử dụng';
        case 'PROMOTION_MOVIE_MISMATCH':
          return 'Mã khuyến mãi không áp dụng cho phim này';
        case 'ORDER_TOTAL_ZERO':
          return 'Đơn hàng có tổng tiền bằng 0 không thể áp dụng mã';
        case 'BOOKING_NOT_PENDING':
          return 'Đơn hàng không ở trạng thái chờ thanh toán';
        case 'BOOKING_EXPIRED':
          return 'Đơn hàng đã hết hạn thanh toán';
        default:
          return e.message;
      }
    }
    return e.toString();
  }
}
