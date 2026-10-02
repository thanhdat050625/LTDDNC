import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class PromotionFormCubit extends Cubit<PromotionFormState> {
  final PromotionManagementRepository _repository;

  PromotionFormCubit(this._repository) : super(PromotionFormInitial());

  Future<void> submit({required bool isEdit, int? promotionId, required Map<String, dynamic> data}) async {
    try {
      emit(PromotionFormSubmitting());
      if (isEdit && promotionId != null) {
        await _repository.updatePromotion(promotionId, data);
      } else {
        await _repository.createPromotion(data);
      }
      emit(PromotionFormSuccess());
    } catch (e) {
      if (e is ServerException) {
        emit(PromotionFormError(e.message));
      } else {
        emit(PromotionFormError('Lỗi lưu khuyến mãi: $e'));
      }
    }
  }
}
