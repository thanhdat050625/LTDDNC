import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class RoomManagementCubit extends Cubit<RoomManagementState> {
  final CinemaManagementRepository _repository;

  RoomManagementCubit(this._repository) : super(RoomManagementInitial());

  Future<void> loadRooms(int cinemaId) async {
    try {
      emit(RoomManagementLoading());
      final rooms = await _repository.getRoomsByCinemaId(cinemaId);
      emit(RoomManagementLoaded(rooms));
    } catch (e) {
      if (e is ServerException) {
        emit(RoomManagementError(e.message));
      } else {
        emit(RoomManagementError('Lỗi tải danh sách phòng: $e'));
      }
    }
  }

  Future<void> deleteRoom(int roomId, int cinemaId) async {
    try {
      await _repository.deleteRoom(roomId);
      loadRooms(cinemaId);
    } catch (e) {
      if (e is ServerException) {
        emit(RoomManagementError(e.message));
      } else {
        emit(RoomManagementError('Lỗi xóa phòng: $e'));
      }
    }
  }
}
