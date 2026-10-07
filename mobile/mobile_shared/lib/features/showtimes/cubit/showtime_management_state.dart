import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class ShowtimeManagementState extends Equatable {
  const ShowtimeManagementState();

  @override
  List<Object?> get props => [];
}

class ShowtimeManagementInitial extends ShowtimeManagementState {}

class ShowtimeManagementLoading extends ShowtimeManagementState {}

class ShowtimeManagementLoaded extends ShowtimeManagementState {
  final List<ShowtimeModel> showtimes;
  final List<ShowtimeModel> dateShowtimes;
  final DateTime? selectedDate;
  final int? selectedCinemaId;
  final String? selectedStatus;

  const ShowtimeManagementLoaded({
    required this.showtimes,
    this.dateShowtimes = const [],
    this.selectedDate,
    this.selectedCinemaId,
    this.selectedStatus,
  });

  @override
  List<Object?> get props => [
        showtimes,
        dateShowtimes,
        selectedDate,
        selectedCinemaId,
        selectedStatus,
      ];
}

class ShowtimeManagementError extends ShowtimeManagementState {
  final String message;

  const ShowtimeManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
