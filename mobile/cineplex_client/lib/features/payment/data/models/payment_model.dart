import 'package:equatable/equatable.dart';

class CheckoutPrepareModel extends Equatable {
  final String bookingId;
  final String bookingCode;
  final num totalAmount;
  final num discountAmount;
  final num pointsUsed;
  final int secondsRemaining;
  final String? promotionCode;

  const CheckoutPrepareModel({
    required this.bookingId,
    required this.bookingCode,
    required this.totalAmount,
    this.discountAmount = 0,
    this.pointsUsed = 0,
    this.secondsRemaining = 300,
    this.promotionCode,
  });

  factory CheckoutPrepareModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPrepareModel(
      bookingId: json['bookingId']?.toString() ?? '',
      bookingCode: json['bookingCode'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
      pointsUsed: json['pointsUsed'] ?? 0,
      secondsRemaining: json['secondsRemaining'] ?? 300,
      promotionCode: json['promotion'] != null ? json['promotion']['code'] : json['promotionCode'],
    );
  }

  CheckoutPrepareModel copyWith({
    String? bookingId,
    String? bookingCode,
    num? totalAmount,
    num? discountAmount,
    num? pointsUsed,
    int? secondsRemaining,
    String? promotionCode,
  }) {
    return CheckoutPrepareModel(
      bookingId: bookingId ?? this.bookingId,
      bookingCode: bookingCode ?? this.bookingCode,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      promotionCode: promotionCode,
    );
  }

  @override
  List<Object?> get props => [bookingId, bookingCode, totalAmount, discountAmount, pointsUsed, secondsRemaining, promotionCode];
}

class PaymentResponseModel extends Equatable {
  final String bookingId;
  final String payUrl;
  final bool paymentRequired;

  const PaymentResponseModel({
    required this.bookingId,
    required this.payUrl,
    required this.paymentRequired,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentResponseModel(
      bookingId: json['bookingId'] ?? '',
      payUrl: json['payUrl'] ?? '',
      paymentRequired: json['paymentRequired'] ?? true,
    );
  }

  @override
  List<Object?> get props => [bookingId, payUrl, paymentRequired];
}

class PaymentStatusModel extends Equatable {
  final String bookingId;
  final String bookingCode;
  final String status;
  final String? paymentMethod;
  final bool canRetry;
  final bool isExpired;

  const PaymentStatusModel({
    required this.bookingId,
    required this.bookingCode,
    required this.status,
    this.paymentMethod,
    this.canRetry = false,
    this.isExpired = false,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      bookingId: (json['bookingId'] ?? '').toString(),
      bookingCode: json['bookingCode'] ?? '',
      status: json['status'] ?? json['bookingStatus'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'],
      canRetry: json['canRetry'] == true,
      isExpired: json['isExpired'] == true,
    );
  }

  @override
  List<Object?> get props => [bookingId, bookingCode, status, paymentMethod, canRetry, isExpired];
}
