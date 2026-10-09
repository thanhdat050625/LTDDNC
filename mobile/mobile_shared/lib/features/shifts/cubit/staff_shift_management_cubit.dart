import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class StaffShiftManagementCubit extends Cubit<StaffShiftManagementState> {
  final ShiftRepository _shiftRepository;
  final CinemaManagementRepository _cinemaRepository;
  final DioClient _dioClient;

  List<ShiftModel> _shifts = [];
  List<CinemaModel> _cinemas = [];
  List<UserModel> _staffList = [];
  int? _selectedCinemaId;
  DateTime _selectedDate = DateTime.now();

  StaffShiftManagementCubit(
    this._shiftRepository,
    this._cinemaRepository,
    this._dioClient,
  ) : super(StaffShiftManagementInitial());

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> loadInitialData({int? cinemaId, DateTime? date}) async {
    try {
      emit(StaffShiftManagementLoading());

      if (date != null) {
        _selectedDate = date;
      }

      // 1. Tải danh sách ca làm việc mẫu
      final shiftsFuture = _shiftRepository.getAllShifts();

      // 2. Tải danh sách rạp chiếu
      final cinemasFuture = _cinemaRepository.getAllCinemas();

      // 3. Tải danh sách nhân viên
      final staffFuture = _dioClient.get('/users', queryParameters: {
        'role': 'STAFF',
        'limit': 100,
      }).then((res) {
        final data = res.data;
        List<dynamic> items = [];
        if (data is Map && data.containsKey('data')) {
          final payload = data['data'];
          if (payload is Map && payload.containsKey('items')) {
            items = payload['items'] as List<dynamic>;
          } else if (payload is List) {
            items = payload;
          }
        } else if (data is List) {
          items = data;
        }
        return items
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });

      final results = await Future.wait([shiftsFuture, cinemasFuture, staffFuture]);
      _shifts = results[0] as List<ShiftModel>;
      _cinemas = results[1] as List<CinemaModel>;
      _staffList = results[2] as List<UserModel>;

      if (cinemaId != null) {
        _selectedCinemaId = cinemaId;
      } else if (_selectedCinemaId == null && _cinemas.isNotEmpty) {
        _selectedCinemaId = _cinemas.first.id;
      }

      // 4. Tải lịch phân ca của ngày được chọn
      await _fetchSchedules();
    } catch (e) {
      if (e is AppException) {
        emit(StaffShiftManagementError(e.message));
      } else {
        emit(StaffShiftManagementError('Lỗi tải dữ liệu: $e'));
      }
    }
  }

  Future<void> _fetchSchedules() async {
    try {
      final dateStr = _formatDate(_selectedDate);
      final schedules = await _shiftRepository.getSchedules(
        cinemaId: _selectedCinemaId,
        startDate: dateStr,
        endDate: dateStr,
      );

      emit(StaffShiftManagementLoaded(
        shifts: _shifts,
        cinemas: _cinemas,
        staffList: _staffList,
        schedules: schedules,
        selectedCinemaId: _selectedCinemaId,
        selectedDate: _selectedDate,
      ));
    } catch (e) {
      if (e is AppException) {
        emit(StaffShiftManagementError(e.message));
      } else {
        emit(StaffShiftManagementError('Lỗi tải lịch phân ca: $e'));
      }
    }
  }

  void selectCinema(int cinemaId) {
    if (_selectedCinemaId != cinemaId) {
      _selectedCinemaId = cinemaId;
      _fetchSchedules();
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _fetchSchedules();
  }

  Future<bool> createSchedule({
    required int staffId,
    required int cinemaId,
    required int shiftId,
    required String workDate,
    required String assignedRole,
    String? note,
  }) async {
    return createMultipleSchedules(
      staffIds: [staffId],
      cinemaId: cinemaId,
      shiftId: shiftId,
      workDate: workDate,
      assignedRole: assignedRole,
      note: note,
    );
  }

  Future<bool> createMultipleSchedules({
    required List<int> staffIds,
    required int cinemaId,
    required int shiftId,
    required String workDate,
    required String assignedRole,
    String? note,
  }) async {
    if (staffIds.isEmpty) return false;
    try {
      final futures = staffIds.map((staffId) => _shiftRepository.createSchedule({
            'staffId': staffId,
            'cinemaId': cinemaId,
            'shiftId': shiftId,
            'workDate': workDate,
            'assignedRole': assignedRole,
            if (note != null && note.isNotEmpty) 'note': note,
          }));
      await Future.wait(futures);
      await _fetchSchedules();
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Lỗi phân ca làm: $e';
      emit(StaffShiftManagementError(msg));
      // Re-emit loaded state after showing error
      _fetchSchedules();
      return false;
    }
  }

  Future<bool> updateSchedule(int id, Map<String, dynamic> data) async {
    try {
      await _shiftRepository.updateSchedule(id, data);
      await _fetchSchedules();
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Lỗi cập nhật ca làm: $e';
      emit(StaffShiftManagementError(msg));
      _fetchSchedules();
      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      await _shiftRepository.deleteSchedule(id);
      await _fetchSchedules();
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Lỗi hủy ca làm: $e';
      emit(StaffShiftManagementError(msg));
      _fetchSchedules();
      return false;
    }
  }

  Future<bool> syncSchedules({
    required int cinemaId,
    required List<int> shiftIds,
    required List<int> staffIds,
    required List<String> dates,
    required List<int> initialShiftIds,
    required List<int> initialStaffIds,
  }) async {
    try {
      await _shiftRepository.bulkSyncSchedules({
        'cinemaId': cinemaId,
        'shiftIds': shiftIds,
        'staffIds': staffIds,
        'dates': dates,
        'initialShiftIds': initialShiftIds,
        'initialStaffIds': initialStaffIds,
        'assignedRole': 'GENERAL',
      });
      await _fetchSchedules();
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Lỗi đồng bộ phân ca: $e';
      emit(StaffShiftManagementError(msg));
      _fetchSchedules();
      return false;
    }
  }
}
