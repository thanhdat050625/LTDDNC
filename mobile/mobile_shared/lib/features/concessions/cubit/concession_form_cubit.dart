import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ConcessionFormCubit extends Cubit<ConcessionFormState> {
  final ConcessionManagementRepository _repository;

  ConcessionFormCubit(this._repository) : super(ConcessionFormInitial());

  Future<void> submit({required bool isEdit, int? concessionId, required Map<String, dynamic> data}) async {
    try {
      emit(ConcessionFormSubmitting());
      if (isEdit && concessionId != null) {
        await _repository.updateConcession(concessionId, data);
      } else {
        await _repository.createConcession(data);
      }
      emit(ConcessionFormSuccess());
    } catch (e) {
      if (e is ServerException) {
        emit(ConcessionFormError(e.message));
      } else {
        emit(ConcessionFormError('Lỗi lưu bắp nước: $e'));
      }
    }
  }
}
