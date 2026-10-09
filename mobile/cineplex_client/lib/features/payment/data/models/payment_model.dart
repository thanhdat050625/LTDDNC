import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

class CheckoutSeatItem extends Equatable {
  final int id;
  final String row;
  final int column;
  final String? roomType;

  const CheckoutSeatItem({
    required this.id,
    required this.row,
    required this.column,
    this.roomType,
  });

  String get seatName => '$row$column';

  factory CheckoutSeatItem.fromJson(Map<String, dynamic> json) {
    return CheckoutSeatItem(
      id: json['id'] as int? ?? 0,
      row: json['row']?.toString() ?? '',
      column: json['column'] as int? ?? 0,
      roomType: json['roomType']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, row, column, roomType];
}

class CheckoutConcessionItem extends Equatable {
  final int productId;
  final String name;
  final int quantity;
  final num unitPrice;
  final num subtotal;

  const CheckoutConcessionItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory CheckoutConcessionItem.fromJson(Map<String, dynamic> json) {
    return CheckoutConcessionItem(
      productId: json['productId'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: json['unitPrice'] as num? ?? 0,
      subtotal: json['subtotal'] as num? ?? 0,
    );
  }

  @override
  List<Object?> get props => [productId, name, quantity, unitPrice, subtotal];
}

class CheckoutPrepareModel extends Equatable {
  final String bookingId;
  final String bookingCode;
  final num totalAmount;
  final num discountAmount;
  final num pointsUsed;
  final int secondsRemaining;
  final String? promotionCode;
  final List<CheckoutSeatItem> seats;
  final List<CheckoutConcessionItem> concessions;
  final num loyaltyPoints;
  final num ticketTotal;
  final num concessionTotal;
  final num estimatedPointsEarned;

  const CheckoutPrepareModel({
    required this.bookingId,
    required this.bookingCode,
    required this.totalAmount,
    this.discountAmount = 0,
    this.pointsUsed = 0,
    this.secondsRemaining = 300,
    this.promotionCode,
    this.seats = const [],
    this.concessions = const [],
    this.loyaltyPoints = 0,
    this.ticketTotal = 0,
    this.concessionTotal = 0,
    this.estimatedPointsEarned = 0,
  });

  factory CheckoutPrepareModel.fromJson(Map<String, dynamic> json) {
    final rawSeats = json['seats'] as List? ?? [];
    final rawConcessions = json['concessions'] as List? ?? [];

    final concessionsList = rawConcessions
        .map((c) => CheckoutConcessionItem.fromJson(c as Map<String, dynamic>))
        .toList();

    final cTotal = json['concessionTotal'] as num? ??
        concessionsList.fold<num>(0, (sum, item) => sum + item.subtotal);

    final totAmt = json['totalAmount'] as num? ?? 0;
    final discAmt = json['discountAmount'] as num? ?? 0;
    final ptsUsed = json['pointsUsed'] as num? ?? 0;
    final orderOriginal = totAmt + discAmt + ptsUsed;
    final tTotal = json['ticketTotal'] as num? ?? (orderOriginal - cTotal).clamp(0, double.infinity);

    return CheckoutPrepareModel(
      bookingId: json['bookingId']?.toString() ?? '',
      bookingCode: json['bookingCode'] ?? '',
      totalAmount: totAmt,
      discountAmount: discAmt,
      pointsUsed: ptsUsed,
      secondsRemaining: json['secondsRemaining'] ?? 300,
      promotionCode: json['promotion'] != null ? json['promotion']['code'] : json['promotionCode'],
      seats: rawSeats.map((s) => CheckoutSeatItem.fromJson(s as Map<String, dynamic>)).toList(),
      concessions: concessionsList,
      loyaltyPoints: json['loyaltyPoints'] as num? ?? 0,
      ticketTotal: tTotal,
      concessionTotal: cTotal,
      estimatedPointsEarned: json['estimatedPointsEarned'] as num? ?? (totAmt * 0.10).floor(),
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
    List<CheckoutSeatItem>? seats,
    List<CheckoutConcessionItem>? concessions,
    num? loyaltyPoints,
    num? ticketTotal,
    num? concessionTotal,
    num? estimatedPointsEarned,
  }) {
    return CheckoutPrepareModel(
      bookingId: bookingId ?? this.bookingId,
      bookingCode: bookingCode ?? this.bookingCode,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      promotionCode: promotionCode,
      seats: seats ?? this.seats,
      concessions: concessions ?? this.concessions,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      ticketTotal: ticketTotal ?? this.ticketTotal,
      concessionTotal: concessionTotal ?? this.concessionTotal,
      estimatedPointsEarned: estimatedPointsEarned ?? this.estimatedPointsEarned,
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        bookingCode,
        totalAmount,
        discountAmount,
        pointsUsed,
        secondsRemaining,
        promotionCode,
        seats,
        concessions,
        loyaltyPoints,
        ticketTotal,
        concessionTotal,
        estimatedPointsEarned,
      ];
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
      bookingId: (json['bookingId'] ?? '').toString(),
      payUrl: (json['payUrl'] ?? '').toString(),
      paymentRequired: json['paymentRequired'] == true ||
          (json['payUrl'] != null && json['payUrl'].toString().isNotEmpty),
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
  final int? showtimeId;

  const PaymentStatusModel({
    required this.bookingId,
    required this.bookingCode,
    required this.status,
    this.paymentMethod,
    this.canRetry = false,
    this.isExpired = false,
    this.showtimeId,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      bookingId: (json['bookingId'] ?? '').toString(),
      bookingCode: (json['bookingCode'] ?? '').toString(),
      status: (json['status'] ?? json['bookingStatus'] ?? 'PENDING').toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      canRetry: json['canRetry'] == true,
      isExpired: json['isExpired'] == true,
      showtimeId: (json['showtimeId'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => [bookingId, bookingCode, status, paymentMethod, canRetry, isExpired, showtimeId];
}

class CheckoutScreenArgs extends Equatable {
  final int showtimeId;
  final List<int> seatIds;
  final double seatPrice;
  final List<ConcessionItemDto> concessions;

  const CheckoutScreenArgs({
    this.showtimeId = 0,
    this.seatIds = const [],
    this.seatPrice = 0.0,
    this.concessions = const [],
  });

  @override
  List<Object?> get props => [showtimeId, seatIds, seatPrice, concessions];
}
