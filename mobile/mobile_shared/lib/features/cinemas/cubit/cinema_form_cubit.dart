import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class CinemaFormCubit extends Cubit<CinemaFormState> {
  final CinemaManagementRepository _repository;

  CinemaFormCubit(this._repository) : super(CinemaFormInitial());

  Future<void> submit({required bool isEdit, int? cinemaId, required Map<String, dynamic> data}) async {
    try {
      emit(CinemaFormSubmitting());
      if (isEdit && cinemaId != null) {
        await _repository.updateCinema(cinemaId, data);
      } else {
        await _repository.createCinema(data);
      }
      emit(CinemaFormSuccess());
    } catch (e) {
      if (e is ServerException) {
        emit(CinemaFormError(e.message));
      } else {
        emit(CinemaFormError('Lỗi lưu rạp: $e'));
      }
    }
  }
}
