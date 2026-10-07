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
  final String? movieTitle;
  final String? roomName;
  final String? cinemaName;
  final String? startTime;
  final String? customerName;
  final String? bookingCode;

  const TicketModel({
    required this.id,
    required this.bookingId,
    required this.seatId,
    required this.qrCode,
    required this.price,
    this.isCheckedIn = false,
    required this.status,
    this.seatLabel,
    this.movieTitle,
    this.roomName,
    this.cinemaName,
    this.startTime,
    this.customerName,
    this.bookingCode,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    String? label;
    if (json['seat'] is Map) {
      final seat = json['seat'] as Map<String, dynamic>;
      label =
          seat['label']?.toString() ??
          '${seat['row'] ?? ''}${seat['column'] ?? seat['number'] ?? ''}';
    }

    final showtime = json['showtime'] as Map<String, dynamic>?;
    final movie = showtime?['movie'] as Map<String, dynamic>?;
    final room = showtime?['room'] as Map<String, dynamic>?;
    final cinema = room?['cinema'] as Map<String, dynamic>?;
    final booking = json['booking'] as Map<String, dynamic>?;
    final customer = booking?['customer'] as Map<String, dynamic>?;

    return TicketModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      seatId: json['seatId']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
      price: json['price'] ?? 0,
      isCheckedIn: json['isCheckedIn'] ?? false,
      status: json['status']?.toString() ?? 'ACTIVE',
      seatLabel: label ?? json['seatLabel']?.toString(),
      movieTitle: movie?['title']?.toString(),
      roomName: room?['name']?.toString(),
      cinemaName: cinema?['name']?.toString(),
      startTime:
          showtime?['publicStartTime']?.toString() ??
          showtime?['startTime']?.toString(),
      customerName:
          customer?['fullName']?.toString() ?? customer?['name']?.toString(),
      bookingCode: booking?['bookingCode']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    seatId,
    qrCode,
    price,
    isCheckedIn,
    status,
    seatLabel,
    movieTitle,
    roomName,
    cinemaName,
    startTime,
    customerName,
    bookingCode,
  ];
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
  final String? customerName;
  final String? customerPhone;
  final String? staffName;
  final String? createdAt;
  final String? paymentMethod;
  final num discountAmount;
  final String? source;

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
    this.customerName,
    this.customerPhone,
    this.staffName,
    this.createdAt,
    this.paymentMethod,
    this.discountAmount = 0,
    this.source,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    final showtime = json['showtime'] as Map<String, dynamic>?;
    final movie = showtime?['movie'] as Map<String, dynamic>?;
    final room = showtime?['room'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    final staff = json['staff'] as Map<String, dynamic>?;
    final payment = json['payment'] as Map<String, dynamic>?;

    return BookingDetailModel(
      id: json['id']?.toString() ?? '',
      bookingCode: json['bookingCode']?.toString() ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status']?.toString() ?? '',
      movieTitle: movie?['title']?.toString(),
      posterUrl: movie?['posterUrl']?.toString(),
      cinemaName: room?['cinema']?['name']?.toString() ?? 'Cineplex',
      roomName: room?['name']?.toString(),
      startTime:
          showtime?['publicStartTime']?.toString() ??
          showtime?['startTime']?.toString(),
      format: showtime?['format']?.toString() ?? '2D',
      tickets:
          (json['tickets'] as List?)
              ?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      concessions:
          (json['bookingConcessions'] as List?)?.cast<Map<String, dynamic>>() ??
          [],
      customerName: user?['fullName']?.toString() ?? user?['name']?.toString(),
      customerPhone:
          user?['phone']?.toString() ?? user?['phoneNumber']?.toString(),
      staffName: staff?['fullName']?.toString() ?? staff?['name']?.toString(),
      createdAt: json['createdAt']?.toString(),
      paymentMethod: payment?['method']?.toString(),
      discountAmount: json['discountAmount'] ?? 0,
      source: json['source']?.toString(),
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
    customerName,
    customerPhone,
    staffName,
    createdAt,
    paymentMethod,
    discountAmount,
    source,
  ];
}

class TicketPriceModel extends Equatable {
  final int id;
  final String roomType;
  final String dayType;
  final num price;

  const TicketPriceModel({
    required this.id,
    required this.roomType,
    required this.dayType,
    required this.price,
  });

  factory TicketPriceModel.fromJson(Map<String, dynamic> json) {
    return TicketPriceModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      roomType: json['roomType']?.toString() ?? 'STANDARD',
      dayType: json['dayType']?.toString() ?? 'WEEKDAY',
      price: json['price'] is num
          ? json['price'] as num
          : num.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, roomType, dayType, price];
}
