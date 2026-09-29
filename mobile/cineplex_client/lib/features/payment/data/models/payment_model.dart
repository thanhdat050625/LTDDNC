import 'package:equatable/equatable.dart';

class CheckoutPrepareModel extends Equatable {
  final String bookingId;
  final String bookingCode;
  final num totalAmount;
  final num discountAmount;
  final num pointsUsed;
  final int secondsRemaining;

  const CheckoutPrepareModel({
    required this.bookingId,
    required this.bookingCode,
    required this.totalAmount,
    this.discountAmount = 0,
    this.pointsUsed = 0,
    this.secondsRemaining = 300,
  });

  factory CheckoutPrepareModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPrepareModel(
      bookingId: json['bookingId'] ?? '',
      bookingCode: json['bookingCode'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
      pointsUsed: json['pointsUsed'] ?? 0,
      secondsRemaining: json['secondsRemaining'] ?? 300,
    );
  }

  @override
  List<Object?> get props => [bookingId, bookingCode, totalAmount, discountAmount, pointsUsed, secondsRemaining];
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

  const PaymentStatusModel({
    required this.bookingId,
    required this.bookingCode,
    required this.status,
    this.paymentMethod,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      bookingId: json['bookingId'] ?? '',
      bookingCode: json['bookingCode'] ?? '',
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'],
    );
  }

  @override
  List<Object?> get props => [bookingId, bookingCode, status, paymentMethod];
}
