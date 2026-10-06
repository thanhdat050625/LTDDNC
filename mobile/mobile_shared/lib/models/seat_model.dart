import 'package:equatable/equatable.dart';

enum SeatStatus { available, selected, held, booked, maintenance }
enum SeatType { standard, vip, couple }

class SeatModel extends Equatable {
  final int seatId;
  final String row;
  final int column;
  final String label;
  final SeatStatus status;
  final bool isCouple;
  final bool isVip;
  final SeatType type;
  final double price;

  const SeatModel({
    required this.seatId,
    required this.row,
    required this.column,
    required this.label,
    required this.status,
    required this.isCouple,
    this.isVip = false,
    SeatType? type,
    this.price = 0.0,
  }) : type = type ?? (isCouple ? SeatType.couple : (isVip ? SeatType.vip : SeatType.standard));

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    SeatStatus parsedStatus = SeatStatus.available;
    final rawStatus = (json['status'] as String?)?.toLowerCase();
    switch (rawStatus) {
      case 'booked':
        parsedStatus = SeatStatus.booked;
        break;
      case 'selected':
      case 'held':
        parsedStatus = SeatStatus.held;
        break;
      case 'maintenance':
      case 'blocked':
        parsedStatus = SeatStatus.maintenance;
        break;
      default:
        parsedStatus = SeatStatus.available;
    }

    final String row = json['row'] as String? ?? 'A';
    final int column = (json['column'] ?? json['number'] ?? 0) as int;
    final int seatId = (json['seatId'] ?? json['id'] ?? 0) as int;
    final String label = (json['label'] ?? '$row$column') as String;
    final bool isCouple = json['isCouple'] as bool? ?? false;
    final bool isVip = json['isVip'] as bool? ?? (json['type'] == 'VIP');
    final SeatType type = isCouple
        ? SeatType.couple
        : (isVip ? SeatType.vip : SeatType.standard);
    final double price = (json['price'] as num?)?.toDouble() ?? 0.0;

    return SeatModel(
      seatId: seatId,
      row: row,
      column: column,
      label: label,
      status: parsedStatus,
      isCouple: isCouple,
      isVip: isVip,
      type: type,
      price: price,
    );
  }

  SeatModel copyWith({
    int? seatId,
    String? row,
    int? column,
    String? label,
    SeatStatus? status,
    bool? isCouple,
    bool? isVip,
    SeatType? type,
    double? price,
  }) {
    return SeatModel(
      seatId: seatId ?? this.seatId,
      row: row ?? this.row,
      column: column ?? this.column,
      label: label ?? this.label,
      status: status ?? this.status,
      isCouple: isCouple ?? this.isCouple,
      isVip: isVip ?? this.isVip,
      type: type ?? this.type,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [seatId, row, column, label, status, isCouple, isVip, type, price];
}
