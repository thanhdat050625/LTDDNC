import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class RoomManagementCubit extends Cubit<RoomManagementState> {
  final CinemaManagementRepository _repository;
  List<RoomModel> _allRooms = [];
  String? _selectedStatus;

  RoomManagementCubit(this._repository) : super(RoomManagementInitial());

  Future<void> loadRooms(int cinemaId) async {
    try {
      emit(RoomManagementLoading());
      final rooms = await _repository.getRoomsByCinemaId(cinemaId);
      _allRooms = rooms;
      _applyFilters();
    } catch (e) {
      if (e is ServerException) {
        emit(RoomManagementError(e.message));
      } else {
        emit(RoomManagementError('Lỗi tải danh sách phòng: $e'));
      }
    }
  }

  // ponytail: In-memory room filtering; upgrade to paginated query params if room count exceeds 100 per cinema.
  void filterByStatus(String? status) {
    if (status == null || _selectedStatus == status) {
      _selectedStatus = null;
    } else {
      _selectedStatus = status;
    }
    if (state is RoomManagementLoaded) {
      _applyFilters();
    }
  }

  void _applyFilters() {
    var filtered = _allRooms;
    if (_selectedStatus != null) {
      filtered = filtered
          .where((r) => r.status.toUpperCase() == _selectedStatus!.toUpperCase())
          .toList();
    }
    emit(RoomManagementLoaded(
      rooms: filtered,
      allRooms: _allRooms,
      selectedStatus: _selectedStatus,
    ));
  }

  Future<void> deleteRoom(int roomId, int cinemaId) async {
    try {
      await _repository.deleteRoom(roomId);
      await loadRooms(cinemaId);
    } catch (e) {
      if (state is! RoomManagementLoaded) {
        if (e is ServerException) {
          emit(RoomManagementError(e.message));
        } else {
          emit(RoomManagementError('Lỗi xóa phòng: $e'));
        }
      }
      rethrow;
    }
  }
}
