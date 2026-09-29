import 'package:equatable/equatable.dart';

class TicketModel extends Equatable {
  final String id;
  final String bookingId;
  final String seatId;
  final String qrCode;
  final num price;
  final bool isCheckedIn;
  final String status;
  final String? seatLabel;

  const TicketModel({
    required this.id,
    required this.bookingId,
    required this.seatId,
    required this.qrCode,
    required this.price,
    this.isCheckedIn = false,
    required this.status,
    this.seatLabel,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    String? label;
    if (json['seat'] is Map) {
      final seat = json['seat'] as Map<String, dynamic>;
      label = seat['label'] ?? '${seat['row'] ?? ''}${seat['column'] ?? seat['number'] ?? ''}';
    }

    return TicketModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      seatId: json['seatId']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
      price: json['price'] ?? 0,
      isCheckedIn: json['isCheckedIn'] ?? false,
      status: json['status']?.toString() ?? 'ACTIVE',
      seatLabel: label,
    );
  }

  @override
  List<Object?> get props => [id, bookingId, seatId, qrCode, price, isCheckedIn, status, seatLabel];
}

class BookingDetailModel extends Equatable {
  final String id;
  final String bookingCode;
  final num totalAmount;
  final String status;
  final String? movieTitle;
  final String? posterUrl;
  final String? cinemaName;
  final String? roomName;
  final String? startTime;
  final String? format;
  final List<TicketModel> tickets;
  final List<Map<String, dynamic>> concessions;

  const BookingDetailModel({
    required this.id,
    required this.bookingCode,
    required this.totalAmount,
    required this.status,
    this.movieTitle,
    this.posterUrl,
    this.cinemaName,
    this.roomName,
    this.startTime,
    this.format,
    required this.tickets,
    this.concessions = const [],
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    final showtime = json['showtime'] as Map<String, dynamic>?;
    final movie = showtime?['movie'] as Map<String, dynamic>?;
    final room = showtime?['room'] as Map<String, dynamic>?;

    return BookingDetailModel(
      id: json['id']?.toString() ?? '',
      bookingCode: json['bookingCode']?.toString() ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status']?.toString() ?? '',
      movieTitle: movie?['title']?.toString(),
      posterUrl: movie?['posterUrl']?.toString(),
      cinemaName: room?['cinema']?['name']?.toString() ?? 'Cineplex',
      roomName: room?['name']?.toString(),
      startTime: showtime?['publicStartTime']?.toString() ?? showtime?['startTime']?.toString(),
      format: showtime?['format']?.toString() ?? '2D',
      tickets: (json['tickets'] as List?)?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      concessions: (json['bookingConcessions'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingCode,
        totalAmount,
        status,
        movieTitle,
        posterUrl,
        cinemaName,
        roomName,
        startTime,
        format,
        tickets,
        concessions,
      ];
}
