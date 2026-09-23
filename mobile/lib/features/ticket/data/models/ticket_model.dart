import 'package:equatable/equatable.dart';

class TicketModel extends Equatable {
  final String id;
  final String bookingId;
  final String seatId;
  final String qrCode;
  final num price;
  final bool isCheckedIn;
  final String status;

  const TicketModel({
    required this.id,
    required this.bookingId,
    required this.seatId,
    required this.qrCode,
    required this.price,
    this.isCheckedIn = false,
    required this.status,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      seatId: json['seatId'] ?? '',
      qrCode: json['qrCode'] ?? '',
      price: json['price'] ?? 0,
      isCheckedIn: json['isCheckedIn'] ?? false,
      status: json['status'] ?? 'ACTIVE',
    );
  }

  @override
  List<Object?> get props => [id, bookingId, seatId, qrCode, price, isCheckedIn, status];
}

class BookingDetailModel extends Equatable {
  final String id;
  final String bookingCode;
  final num totalAmount;
  final String status;
  final List<TicketModel> tickets;

  const BookingDetailModel({
    required this.id,
    required this.bookingCode,
    required this.totalAmount,
    required this.status,
    required this.tickets,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailModel(
      id: json['id'] ?? '',
      bookingCode: json['bookingCode'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status'] ?? '',
      tickets: (json['tickets'] as List?)?.map((e) => TicketModel.fromJson(e)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, bookingCode, totalAmount, status, tickets];
}
