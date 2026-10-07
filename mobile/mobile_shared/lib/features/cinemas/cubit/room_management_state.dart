import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class RoomManagementState extends Equatable {
  const RoomManagementState();
  @override
  List<Object?> get props => [];
}

class RoomManagementInitial extends RoomManagementState {}
class RoomManagementLoading extends RoomManagementState {}
class RoomManagementLoaded extends RoomManagementState {
  final List<RoomModel> rooms;
  final List<RoomModel> allRooms;
  final String? selectedStatus;

  const RoomManagementLoaded({
    required this.rooms,
    this.allRooms = const [],
    this.selectedStatus,
  });

  @override
  List<Object?> get props => [rooms, allRooms, selectedStatus];
}
class RoomManagementError extends RoomManagementState {
  final String message;
  const RoomManagementError(this.message);
  @override
  List<Object?> get props => [message];
}
