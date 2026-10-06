import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class StaffMyScheduleCubit extends Cubit<StaffMyScheduleState> {
  final ShiftRepository _shiftRepository;
  DateTime _weekStartDate;
  DateTime _selectedDate = DateTime.now();

  StaffMyScheduleCubit(this._shiftRepository)
      : _weekStartDate = _getMondayOfCurrentWeek(DateTime.now()),
        super(StaffMyScheduleInitial());

  static DateTime _getMondayOfCurrentWeek(DateTime date) {
    // weekday: Monday is 1, Sunday is 7
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> loadSchedule({DateTime? weekStart, DateTime? selectedDate}) async {
    try {
      emit(StaffMyScheduleLoading());

      if (weekStart != null) {
        _weekStartDate = _getMondayOfCurrentWeek(weekStart);
      }
      if (selectedDate != null) {
        _selectedDate = selectedDate;
      }

      final weekEnd = _weekStartDate.add(const Duration(days: 6));
      final startDateStr = _formatDate(_weekStartDate);
      final endDateStr = _formatDate(weekEnd);

      final schedules = await _shiftRepository.getMySchedule(
        startDate: startDateStr,
        endDate: endDateStr,
      );

      emit(StaffMyScheduleLoaded(
        schedules: schedules,
        weekStartDate: _weekStartDate,
        selectedDate: _selectedDate,
      ));
    } catch (e) {
      final msg = e is AppException ? e.message : 'Lỗi tải lịch làm việc: $e';
      emit(StaffMyScheduleError(msg));
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    if (state is StaffMyScheduleLoaded) {
      final loaded = state as StaffMyScheduleLoaded;
      emit(loaded.copyWith(selectedDate: date));
    }
  }

  void previousWeek() {
    final prevMonday = _weekStartDate.subtract(const Duration(days: 7));
    loadSchedule(weekStart: prevMonday, selectedDate: prevMonday);
  }

  void nextWeek() {
    final nextMonday = _weekStartDate.add(const Duration(days: 7));
    loadSchedule(weekStart: nextMonday, selectedDate: nextMonday);
  }

  void currentWeek() {
    final now = DateTime.now();
    final thisMonday = _getMondayOfCurrentWeek(now);
    loadSchedule(weekStart: thisMonday, selectedDate: now);
  }
}
