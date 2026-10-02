import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class PromotionManagementCubit extends Cubit<PromotionManagementState> {
  final PromotionManagementRepository _repository;

  PromotionManagementCubit(this._repository) : super(PromotionManagementInitial());

  Future<void> loadPromotions() async {
    try {
      emit(PromotionManagementLoading());
      final promotions = await _repository.getAllPromotions();
      emit(PromotionManagementLoaded(promotions));
    } catch (e) {
      if (e is ServerException) {
        emit(PromotionManagementError(e.message));
      } else {
        emit(PromotionManagementError('Lỗi tải danh sách khuyến mãi: $e'));
      }
    }
  }

  Future<void> deletePromotion(int id) async {
    try {
      await _repository.deletePromotion(id);
      loadPromotions();
    } catch (e) {
      if (e is ServerException) {
        emit(PromotionManagementError(e.message));
      } else {
        emit(PromotionManagementError('Lỗi xóa khuyến mãi: $e'));
      }
    }
  }
}
