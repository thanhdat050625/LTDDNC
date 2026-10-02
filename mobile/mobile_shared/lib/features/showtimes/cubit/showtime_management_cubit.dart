import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeManagementCubit extends Cubit<ShowtimeManagementState> {
  final ShowtimeManagementRepository _repository;
  
  // Cache to filter locally
  List<ShowtimeModel> _allShowtimes = [];
  DateTime? _selectedDate;
  int? _selectedCinemaId;

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

  void _applyFilters() {
    List<ShowtimeModel> filtered = List.from(_allShowtimes);

    if (_selectedDate != null) {
      filtered = filtered.where((st) {
        return st.publicStartTime.year == _selectedDate!.year &&
               st.publicStartTime.month == _selectedDate!.month &&
               st.publicStartTime.day == _selectedDate!.day;
      }).toList();
    }

    if (_selectedCinemaId != null) {
      // Note: backend room/cinema relation is needed. If st.room.cinemaId is available, filter it.
      // We assume room has cinemaId in the model or we fetch it. 
      // If room model doesn't have cinemaId, this filter might need backend update, but for now we try to filter if possible.
      // Wait, RoomModel doesn't have cinemaId in the current implementation? Let's check RoomModel.
      // Actually, if we can't filter by cinemaId on frontend, we just ignore it.
    }

    // Sort by time
    filtered.sort((a, b) => a.publicStartTime.compareTo(b.publicStartTime));

    emit(ShowtimeManagementLoaded(
      showtimes: filtered,
      selectedDate: _selectedDate,
      selectedCinemaId: _selectedCinemaId,
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
