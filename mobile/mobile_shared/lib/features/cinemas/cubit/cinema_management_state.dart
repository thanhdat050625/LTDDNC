import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class CinemaManagementState extends Equatable {
  const CinemaManagementState();
  @override
  List<Object?> get props => [];
}

class CinemaManagementInitial extends CinemaManagementState {}
class CinemaManagementLoading extends CinemaManagementState {}
class CinemaManagementLoaded extends CinemaManagementState {
  final List<CinemaModel> cinemas;
  const CinemaManagementLoaded(this.cinemas);
  @override
  List<Object?> get props => [cinemas];
}
class CinemaManagementError extends CinemaManagementState {
  final String message;
  const CinemaManagementError(this.message);
  @override
  List<Object?> get props => [message];
}
