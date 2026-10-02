import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class CinemaManagementCubit extends Cubit<CinemaManagementState> {
  final CinemaManagementRepository _repository;

  CinemaManagementCubit(this._repository) : super(CinemaManagementInitial());

  Future<void> loadCinemas() async {
    try {
      emit(CinemaManagementLoading());
      final cinemas = await _repository.getAllCinemas();
      emit(CinemaManagementLoaded(cinemas));
    } catch (e) {
      if (e is ServerException) {
        emit(CinemaManagementError(e.message));
      } else {
        emit(CinemaManagementError('Lỗi tải danh sách rạp: $e'));
      }
    }
  }

  Future<void> deleteCinema(int id) async {
    try {
      await _repository.deleteCinema(id);
      loadCinemas();
    } catch (e) {
      // Could emit an error state or a specific delete error
      if (e is ServerException) {
        emit(CinemaManagementError(e.message));
      } else {
        emit(CinemaManagementError('Lỗi xóa rạp: $e'));
      }
    }
  }
}
