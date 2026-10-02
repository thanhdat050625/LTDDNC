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
  const RoomManagementLoaded(this.rooms);
  @override
  List<Object?> get props => [rooms];
}
class RoomManagementError extends RoomManagementState {
  final String message;
  const RoomManagementError(this.message);
  @override
  List<Object?> get props => [message];
}
