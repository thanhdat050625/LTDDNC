import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeManagementCubit extends Cubit<ShowtimeManagementState> {
  final ShowtimeManagementRepository _repository;
  
  // Cache to filter locally
  List<ShowtimeModel> _allShowtimes = [];
  DateTime? _selectedDate;
  int? _selectedCinemaId;
  String? _selectedStatus;

  ShowtimeManagementCubit(this._repository) : super(ShowtimeManagementInitial());

  Future<void> loadShowtimes() async {
    try {
      emit(ShowtimeManagementLoading());
      final showtimes = await _repository.getAllShowtimes(pageSize: 200); // Load enough to filter locally
      _allShowtimes = showtimes;
      _applyFilters();
    } catch (e) {
      if (e is ServerException) {
        emit(ShowtimeManagementError(e.message));
      } else {
        emit(ShowtimeManagementError('Lỗi tải dữ liệu suất chiếu: $e'));
      }
    }
  }

  void filterByDate(DateTime? date) {
    _selectedDate = date;
    if (state is ShowtimeManagementLoaded) {
      _applyFilters();
    }
  }

  void filterByCinema(int? cinemaId) {
    _selectedCinemaId = cinemaId;
    if (state is ShowtimeManagementLoaded) {
      _applyFilters();
    }
  }

  // ponytail: In-memory showtime filtering; upgrade to paginated query params if showtimes exceed 200 per cinema.
  void filterByStatus(String? status) {
    if (status == null || _selectedStatus == status) {
      _selectedStatus = null;
    } else {
      _selectedStatus = status;
    }
    if (state is ShowtimeManagementLoaded) {
      _applyFilters();
    }
  }

  void _applyFilters() {
    List<ShowtimeModel> byDate = List.from(_allShowtimes);

    if (_selectedDate != null) {
      byDate = byDate.where((st) {
        return st.publicStartTime.year == _selectedDate!.year &&
               st.publicStartTime.month == _selectedDate!.month &&
               st.publicStartTime.day == _selectedDate!.day;
      }).toList();
    }

    List<ShowtimeModel> filtered = List.from(byDate);
    if (_selectedCinemaId != null) {
      filtered = filtered
          .where((st) => st.room?.cinemaId == _selectedCinemaId)
          .toList();
    }
    if (_selectedStatus != null) {
      filtered = filtered.where((st) {
        if (_selectedStatus == 'ACTIVE') {
          return st.status.toUpperCase() == 'ACTIVE' || st.status.toUpperCase() == 'BOOKING';
        }
        return st.status.toUpperCase() == _selectedStatus!.toUpperCase();
      }).toList();
    }

    // Sort by time
    filtered.sort((a, b) => a.publicStartTime.compareTo(b.publicStartTime));

    emit(ShowtimeManagementLoaded(
      showtimes: filtered,
      dateShowtimes: byDate,
      selectedDate: _selectedDate,
      selectedCinemaId: _selectedCinemaId,
      selectedStatus: _selectedStatus,
    ));
  }

  Future<void> deleteShowtime(int id) async {
    try {
      await _repository.deleteShowtime(id);
      loadShowtimes(); // Reload after delete
    } catch (e) {
      if (e is ServerException) {
        emit(ShowtimeManagementError(e.message));
      } else {
        emit(ShowtimeManagementError('Lỗi xóa suất chiếu: $e'));
      }
    }
  }
}
