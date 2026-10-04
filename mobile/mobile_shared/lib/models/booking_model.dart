import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  final int id;
  final String bookingCode;
  final int showtimeId;
  final double totalAmount;
  final double discountAmount;
  final int pointsUsed;
  final String status;
  final DateTime? expiredAt;

  const BookingModel({
    required this.id,
    required this.bookingCode,
    required this.showtimeId,
    required this.totalAmount,
    required this.discountAmount,
    required this.pointsUsed,
    required this.status,
    this.expiredAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      bookingCode: json['bookingCode'] as String? ?? '',
      showtimeId: json['showtimeId'] as int,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      pointsUsed: json['pointsUsed'] as int? ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      expiredAt: json['expiredAt'] != null ? DateTime.parse(json['expiredAt'] as String).toLocal() : null,
    );
  }

  @override
  List<Object?> get props => [id, bookingCode, showtimeId, totalAmount, discountAmount, pointsUsed, status, expiredAt];
}

class CreateBookingDto {
  final int showtimeId;
  final List<int> seatIds;
  final List<ConcessionItemDto>? concessions;
  final String? promotionCode;
  final String? source;
  final int? pointsToUse;
  final int? redeemConcessionId;

  CreateBookingDto({
    required this.showtimeId,
    required this.seatIds,
    this.concessions,
    this.promotionCode,
    this.source = 'MOBILE',
    this.pointsToUse,
    this.redeemConcessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'showtimeId': showtimeId,
      'seatIds': seatIds,
      if (concessions != null) 'concessions': concessions!.map((e) => e.toJson()).toList(),
      if (promotionCode != null) 'promotionCode': promotionCode,
      if (source != null) 'source': source,
      if (pointsToUse != null) 'pointsToUse': pointsToUse,
      if (redeemConcessionId != null) 'redeemConcessionId': redeemConcessionId,
    };
  }
}

class ConcessionItemDto {
  final int concessionId;
  final int quantity;

  ConcessionItemDto({required this.concessionId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'productId': concessionId,
    'concessionId': concessionId,
    'quantity': quantity,
  };
}

class UpdateBookingConcessionsDto {
  final List<ConcessionItemDto>? concessions;
  final int? pointsToUse;
  final int? redeemConcessionId;

  UpdateBookingConcessionsDto({this.concessions, this.pointsToUse, this.redeemConcessionId});

  Map<String, dynamic> toJson() => {
    if (concessions != null) 'concessions': concessions!.map((e) => e.toJson()).toList(),
    if (pointsToUse != null) 'pointsToUse': pointsToUse,
    if (redeemConcessionId != null) 'redeemConcessionId': redeemConcessionId,
  };
}
