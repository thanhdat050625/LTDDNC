import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/booking/data/repositories/booking_repository.dart';
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
  final List<PromotionModel> availablePromotions;

  const CheckoutPrepared(
    this.data, {
    this.appliedPromoCode,
    this.availablePromotions = const [],
  });

  CheckoutPrepared copyWith({
    CheckoutPrepareModel? data,
    String? appliedPromoCode,
    bool clearPromoCode = false,
    List<PromotionModel>? availablePromotions,
  }) {
    return CheckoutPrepared(
      data ?? this.data,
      appliedPromoCode: clearPromoCode ? null : (appliedPromoCode ?? this.appliedPromoCode),
      availablePromotions: availablePromotions ?? this.availablePromotions,
    );
  }

  @override
  List<Object?> get props => [data, appliedPromoCode, availablePromotions];
}

class PaymentUrlReady extends PaymentState {
  final String payUrl;
  final String? bookingId;
  final String? bookingCode;
  const PaymentUrlReady(this.payUrl, {this.bookingId, this.bookingCode});
  @override
  List<Object?> get props => [payUrl, bookingId, bookingCode];
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
  final BookingRepository? bookingRepository;
  CheckoutScreenArgs? checkoutArgs;
  String? createdBookingId;

  PaymentCubit(this.repository, [this.bookingRepository]) : super(PaymentInitial());

  Future<void> prepareCheckout(String bookingId) async {
    emit(PaymentLoading());
    try {
      final data = await repository.prepareCheckout(bookingId);
      List<PromotionModel> promos = [];
      try {
        promos = await repository.getActivePromotions();
      } catch (_) {}
      emit(CheckoutPrepared(
        data,
        appliedPromoCode: data.promotionCode,
        availablePromotions: promos,
      ));
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }

  Future<void> prepareCheckoutDraft(CheckoutScreenArgs args) async {
    checkoutArgs = args;
    emit(PaymentLoading());
    try {
      final concessionsPayload = args.concessions
          .map((c) => {'productId': c.concessionId, 'quantity': c.quantity})
          .toList();
      final data = await repository.prepareCheckoutDraft(
        showtimeId: args.showtimeId,
        seatIds: args.seatIds,
        concessions: concessionsPayload,
      );
      List<PromotionModel> promos = [];
      try {
        promos = await repository.getActivePromotions();
      } catch (_) {}
      emit(CheckoutPrepared(
        data,
        appliedPromoCode: null,
        availablePromotions: promos,
      ));
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }

  Future<void> checkout(String bookingId, String method) async {
    final currentPrepared = state is CheckoutPrepared ? (state as CheckoutPrepared) : null;
    emit(PaymentLoading());
    try {
      final data = await repository.checkout(bookingId, method);
      if (data.paymentRequired && data.payUrl.isNotEmpty) {
        emit(PaymentUrlReady(
          data.payUrl,
          bookingId: bookingId,
          bookingCode: currentPrepared?.data.bookingCode,
        ));
      } else {
        checkStatus(bookingId);
      }
    } catch (e) {
      emit(PaymentFailed(e.toString()));
    }
  }

  Future<void> payNow(String bookingId, String method) async {
    final effectiveId = (bookingId != '0' && bookingId.isNotEmpty)
        ? bookingId
        : (createdBookingId ?? '');

    if (effectiveId.isNotEmpty && effectiveId != '0') {
      await checkout(effectiveId, method);
      return;
    }

    if (state is! CheckoutPrepared || checkoutArgs == null || bookingRepository == null) {
      emit(const PaymentFailed('Thiếu thông tin đặt vé để tạo đơn'));
      return;
    }

    final current = state as CheckoutPrepared;
    emit(PaymentLoading());

    try {
      final booking = await bookingRepository!.createBooking(CreateBookingDto(
        showtimeId: checkoutArgs!.showtimeId,
        seatIds: checkoutArgs!.seatIds,
        concessions: checkoutArgs!.concessions,
        promotionCode: current.appliedPromoCode,
        pointsToUse: current.data.pointsUsed.toInt(),
      ));

      createdBookingId = booking.id.toString();
      final data = await repository.checkout(createdBookingId!, method);
      if (data.paymentRequired && data.payUrl.isNotEmpty) {
        emit(PaymentUrlReady(
          data.payUrl,
          bookingId: createdBookingId,
          bookingCode: booking.bookingCode,
        ));
      } else {
        checkStatus(createdBookingId!);
      }
    } catch (e) {
      final errorMsg = _mapPromotionError(e);
      emit(PaymentFailed(errorMsg));
      emit(current);
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
      final current = state as CheckoutPrepared;
      final currentData = current.data;
      if (bookingId == '0' || bookingId.isEmpty) {
        try {
          final subTotal = currentData.ticketTotal + currentData.concessionTotal;
          final res = await repository.checkPromotion(code, orderTotal: subTotal);
          final promoData = (res is Map && res.containsKey('data')) ? res['data'] : res;
          final discountAmount = (promoData is Map && promoData['discountAmount'] != null)
              ? (promoData['discountAmount'] as num)
              : 0;

          final maxPointDiscount = ((subTotal - discountAmount) * 0.20).floor();
          final pointsUsed = currentData.pointsUsed > 0
              ? math.min(currentData.pointsUsed.toInt(), maxPointDiscount)
              : 0;
          final finalTotal = math.max(0, subTotal - discountAmount - pointsUsed);
          final estimatedPoints = (finalTotal * 0.10).floor();

          final updated = currentData.copyWith(
            totalAmount: finalTotal,
            discountAmount: discountAmount,
            pointsUsed: pointsUsed,
            promotionCode: code,
            estimatedPointsEarned: estimatedPoints,
          );
          emit(current.copyWith(data: updated, appliedPromoCode: code));
        } catch (e) {
          final errorMsg = _mapPromotionError(e);
          emit(PaymentFailed(errorMsg));
          emit(current);
        }
        return;
      }

      try {
        final res = await repository.applyPromotion(bookingId, code);
        final totalAmount = (res['totalAmount'] as num?) ?? currentData.totalAmount;
        final discountAmount = (res['discountAmount'] as num?) ?? currentData.discountAmount;
        final promoCode = (res['promotionCode'] as String?) ?? code;
        final estimatedPoints = (totalAmount * 0.10).floor();
        final updated = currentData.copyWith(
          totalAmount: totalAmount,
          discountAmount: discountAmount,
          promotionCode: promoCode,
          estimatedPointsEarned: estimatedPoints,
        );
        emit(current.copyWith(
          data: updated,
          appliedPromoCode: promoCode,
        ));
      } catch (e) {
        final errorMsg = _mapPromotionError(e);
        emit(PaymentFailed(errorMsg));
        emit(current);
      }
    }
  }

  Future<void> removePromotion(String bookingId) async {
    if (state is CheckoutPrepared) {
      final current = state as CheckoutPrepared;
      final currentData = current.data;
      if (bookingId == '0' || bookingId.isEmpty) {
        final subTotal = currentData.ticketTotal + currentData.concessionTotal;
        final maxPointDiscount = (subTotal * 0.20).floor();
        final pointsUsed = currentData.pointsUsed > 0
            ? math.min(currentData.pointsUsed.toInt(), maxPointDiscount)
            : 0;
        final finalTotal = math.max(0, subTotal - pointsUsed);
        final estimatedPoints = (finalTotal * 0.10).floor();

        final updated = currentData.copyWith(
          totalAmount: finalTotal,
          discountAmount: 0,
          pointsUsed: pointsUsed,
          promotionCode: null,
          estimatedPointsEarned: estimatedPoints,
        );
        emit(current.copyWith(data: updated, clearPromoCode: true));
        return;
      }

      try {
        final res = await repository.removePromotion(bookingId);
        final totalAmount = (res['totalAmount'] as num?) ?? (currentData.totalAmount + currentData.discountAmount);
        final estimatedPoints = (totalAmount * 0.10).floor();
        final updated = currentData.copyWith(
          totalAmount: totalAmount,
          discountAmount: 0,
          promotionCode: null,
          estimatedPointsEarned: estimatedPoints,
        );
        emit(current.copyWith(
          data: updated,
          clearPromoCode: true,
        ));
      } catch (e) {
        emit(PaymentFailed(e.toString()));
        emit(current);
      }
    }
  }

  Future<void> applyLoyaltyPoints(String bookingId, int pointsToUse) async {
    if (state is CheckoutPrepared) {
      final current = state as CheckoutPrepared;
      final currentData = current.data;
      if (bookingId == '0' || bookingId.isEmpty) {
        final subTotal = currentData.ticketTotal + currentData.concessionTotal;
        final totalAfterPromo = math.max(0, subTotal - currentData.discountAmount);
        final maxPointDiscount = (totalAfterPromo * 0.20).floor();
        final effectivePoints = math.min(pointsToUse, math.min(currentData.loyaltyPoints.toInt(), maxPointDiscount));
        final finalTotal = math.max(0, totalAfterPromo - effectivePoints);
        final estimatedPoints = (finalTotal * 0.10).floor();

        final updated = currentData.copyWith(
          totalAmount: finalTotal,
          pointsUsed: effectivePoints,
          estimatedPointsEarned: estimatedPoints,
        );
        emit(current.copyWith(data: updated));
        return;
      }

      try {
        final res = await repository.applyLoyaltyPoints(bookingId, pointsToUse);
        final totalAmount = (res['totalAmount'] as num?) ?? currentData.totalAmount;
        final pointsUsed = (res['pointsUsed'] as num?) ?? pointsToUse;
        final estimatedPoints = (totalAmount * 0.10).floor();
        final updated = currentData.copyWith(
          totalAmount: totalAmount,
          pointsUsed: pointsUsed,
          estimatedPointsEarned: estimatedPoints,
        );
        emit(current.copyWith(data: updated));
      } catch (e) {
        emit(PaymentFailed(e.toString()));
        emit(current);
      }
    }
  }

  Future<void> removeLoyaltyPoints(String bookingId) async {
    if (state is CheckoutPrepared) {
      final current = state as CheckoutPrepared;
      final currentData = current.data;
      if (bookingId == '0' || bookingId.isEmpty) {
        final subTotal = currentData.ticketTotal + currentData.concessionTotal;
        final finalTotal = math.max(0, subTotal - currentData.discountAmount);
        final estimatedPoints = (finalTotal * 0.10).floor();

        final updated = currentData.copyWith(
          totalAmount: finalTotal,
          pointsUsed: 0,
          estimatedPointsEarned: estimatedPoints,
        );
        emit(current.copyWith(data: updated));
        return;
      }

      try {
        final res = await repository.removeLoyaltyPoints(bookingId);
        final totalAmount = (res['totalAmount'] as num?) ?? (currentData.totalAmount + currentData.pointsUsed);
        final estimatedPoints = (totalAmount * 0.10).floor();
        final updated = currentData.copyWith(
          totalAmount: totalAmount,
          pointsUsed: 0,
          estimatedPointsEarned: estimatedPoints,
        );
        emit(current.copyWith(data: updated));
      } catch (e) {
        emit(PaymentFailed(e.toString()));
        emit(current);
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
