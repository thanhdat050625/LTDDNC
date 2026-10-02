import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class RoomFormCubit extends Cubit<RoomFormState> {
  final CinemaManagementRepository _repository;

  RoomFormCubit(this._repository) : super(RoomFormInitial());

  Future<void> submit({required bool isEdit, int? roomId, required int cinemaId, required Map<String, dynamic> data}) async {
    try {
      emit(RoomFormSubmitting());
      if (isEdit && roomId != null) {
        await _repository.updateRoom(roomId, data);
      } else {
        await _repository.createRoom(cinemaId, data);
      }
      emit(RoomFormSuccess());
    } catch (e) {
      if (e is ServerException) {
        emit(RoomFormError(e.message));
      } else {
        emit(RoomFormError('Lỗi lưu phòng: $e'));
      }
    }
  }
}
