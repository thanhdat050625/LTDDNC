import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ConcessionFormCubit extends Cubit<ConcessionFormState> {
  final ConcessionManagementRepository _repository;

  ConcessionFormCubit(this._repository) : super(ConcessionFormInitial());

  Future<void> submit({
    required bool isEdit,
    int? concessionId,
    required Map<String, dynamic> data,
    String? imageFilePath,
  }) async {
    try {
      emit(ConcessionFormSubmitting());
      if (isEdit && concessionId != null) {
        await _repository.updateConcession(concessionId, data, imageFilePath: imageFilePath);
      } else {
        await _repository.createConcession(data, imageFilePath: imageFilePath);
      }
      emit(ConcessionFormSuccess());
    } catch (e) {
      if (e is ServerException) {
        emit(ConcessionFormError(e.message));
      } else {
        emit(ConcessionFormError(e.toString()));
      }
    }
  }
}
