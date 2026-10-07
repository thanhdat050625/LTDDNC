import 'package:equatable/equatable.dart';

class CinemaModel extends Equatable {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String status;
  final List<RoomModel>? rooms;
  final int? roomsCount;

  const CinemaModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.status,
    this.rooms,
    this.roomsCount,
  });

  factory CinemaModel.fromJson(Map<String, dynamic> json) {
    final roomsList = (json['rooms'] as List<dynamic>?)
        ?.map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final count = (json['roomsCount'] as num?)?.toInt() ?? roomsList?.length ?? 0;
    return CinemaModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      rooms: roomsList,
      roomsCount: count,
    );
  }

  @override
  List<Object?> get props => [id, name, address, phone, email, status, rooms, roomsCount];
}

class RoomModel extends Equatable {
  final int id;
  final int cinemaId;
  final String name;
  final int totalSeats;
  final int rows;
  final int columns;
  final bool isCouple;
  final String roomType;
  final String status;
  final CinemaModel? cinema;

  const RoomModel({
    required this.id,
    required this.cinemaId,
    required this.name,
    required this.totalSeats,
    required this.rows,
    required this.columns,
    required this.isCouple,
    required this.roomType,
    required this.status,
    this.cinema,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as int,
      cinemaId: json['cinemaId'] as int,
      name: json['name'] as String,
      totalSeats: json['totalSeats'] as int? ?? 0,
      rows: json['rows'] as int? ?? 0,
      columns: json['columns'] as int? ?? 0,
      isCouple: json['isCouple'] as bool? ?? false,
      roomType: json['roomType'] as String? ?? 'STANDARD',
      status: json['status'] as String? ?? 'ACTIVE',
      cinema: json['cinema'] != null ? CinemaModel.fromJson(json['cinema'] as Map<String, dynamic>) : null,
    );
  }

  @override
  List<Object?> get props => [id, cinemaId, name, totalSeats, rows, columns, isCouple, roomType, status, cinema];
}
