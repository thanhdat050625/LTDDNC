import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class StaffShiftManagementState extends Equatable {
  const StaffShiftManagementState();

  @override
  List<Object?> get props => [];
}

class StaffShiftManagementInitial extends StaffShiftManagementState {}

class StaffShiftManagementLoading extends StaffShiftManagementState {}

class StaffShiftManagementLoaded extends StaffShiftManagementState {
  final List<ShiftModel> shifts;
  final List<CinemaModel> cinemas;
  final List<UserModel> staffList;
  final List<StaffScheduleModel> schedules;
  final int? selectedCinemaId;
  final DateTime selectedDate;

  const StaffShiftManagementLoaded({
    required this.shifts,
    required this.cinemas,
    required this.staffList,
    required this.schedules,
    this.selectedCinemaId,
    required this.selectedDate,
  });

  StaffScheduleModel? getScheduleFor(int staffId, int shiftId) {
    try {
      return schedules.firstWhere(
        (s) => s.staffId == staffId && s.shiftId == shiftId,
      );
    } catch (_) {
      return null;
    }
  }

  StaffShiftManagementLoaded copyWith({
    List<ShiftModel>? shifts,
    List<CinemaModel>? cinemas,
    List<UserModel>? staffList,
    List<StaffScheduleModel>? schedules,
    int? selectedCinemaId,
    DateTime? selectedDate,
  }) {
    return StaffShiftManagementLoaded(
      shifts: shifts ?? this.shifts,
      cinemas: cinemas ?? this.cinemas,
      staffList: staffList ?? this.staffList,
      schedules: schedules ?? this.schedules,
      selectedCinemaId: selectedCinemaId ?? this.selectedCinemaId,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [
        shifts,
        cinemas,
        staffList,
        schedules,
        selectedCinemaId,
        selectedDate,
      ];
}

class StaffShiftManagementError extends StaffShiftManagementState {
  final String message;

  const StaffShiftManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
