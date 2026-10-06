import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';

abstract class StaffMyScheduleState extends Equatable {
  const StaffMyScheduleState();

  @override
  List<Object?> get props => [];
}

class StaffMyScheduleInitial extends StaffMyScheduleState {}

class StaffMyScheduleLoading extends StaffMyScheduleState {}

class StaffMyScheduleLoaded extends StaffMyScheduleState {
  final List<StaffScheduleModel> schedules;
  final DateTime weekStartDate;
  final DateTime selectedDate;

  const StaffMyScheduleLoaded({
    required this.schedules,
    required this.weekStartDate,
    required this.selectedDate,
  });

  List<StaffScheduleModel> get schedulesForSelectedDate {
    final y = selectedDate.year.toString().padLeft(4, '0');
    final m = selectedDate.month.toString().padLeft(2, '0');
    final d = selectedDate.day.toString().padLeft(2, '0');
    final dateStr = '$y-$m-$d';
    return schedules.where((s) => s.workDate == dateStr).toList();
  }

  bool hasScheduleOn(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final dateStr = '$y-$m-$d';
    return schedules.any((s) => s.workDate == dateStr);
  }

  StaffMyScheduleLoaded copyWith({
    List<StaffScheduleModel>? schedules,
    DateTime? weekStartDate,
    DateTime? selectedDate,
  }) {
    return StaffMyScheduleLoaded(
      schedules: schedules ?? this.schedules,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [schedules, weekStartDate, selectedDate];
}

class StaffMyScheduleError extends StaffMyScheduleState {
  final String message;

  const StaffMyScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
