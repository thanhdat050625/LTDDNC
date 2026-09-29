import 'package:equatable/equatable.dart';

enum SeatStatus { available, selected, held, booked, maintenance }

class SeatModel extends Equatable {
  final int seatId;
  final String row;
  final int column;
  final String label;
  final SeatStatus status;
  final bool isCouple;

  const SeatModel({
    required this.seatId,
    required this.row,
    required this.column,
    required this.label,
    required this.status,
    required this.isCouple,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    SeatStatus parsedStatus = SeatStatus.available;
    switch (json['status']) {
      case 'booked':
        parsedStatus = SeatStatus.booked;
        break;
      case 'selected':
      case 'held':
        parsedStatus = SeatStatus.held;
        break;
      case 'maintenance':
        parsedStatus = SeatStatus.maintenance;
        break;
      default:
        parsedStatus = SeatStatus.available;
    }

    final String row = json['row'] as String;
    final int column = json['column'] as int;
    
    return SeatModel(
      seatId: json['seatId'] as int,
      row: row,
      column: column,
      label: '$row$column',
      status: parsedStatus,
      isCouple: json['isCouple'] as bool? ?? false,
    );
  }

  SeatModel copyWith({
    int? seatId,
    String? row,
    int? column,
    String? label,
    SeatStatus? status,
    bool? isCouple,
  }) {
    return SeatModel(
      seatId: seatId ?? this.seatId,
      row: row ?? this.row,
      column: column ?? this.column,
      label: label ?? this.label,
      status: status ?? this.status,
      isCouple: isCouple ?? this.isCouple,
    );
  }

  @override
  List<Object?> get props => [seatId, row, column, label, status, isCouple];
}
