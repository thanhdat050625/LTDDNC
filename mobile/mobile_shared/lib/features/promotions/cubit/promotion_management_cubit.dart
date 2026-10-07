import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class PromotionManagementCubit extends Cubit<PromotionManagementState> {
  final PromotionManagementRepository _repository;

  PromotionManagementCubit(this._repository) : super(PromotionManagementInitial());

  Future<void> loadPromotions() async {
    try {
      emit(PromotionManagementLoading());
      final promotions = await _repository.getAllPromotions();
      emit(PromotionManagementLoaded(
        allPromotions: promotions,
        promotions: promotions,
      ));
    } catch (e) {
      if (e is ServerException) {
        emit(PromotionManagementError(e.message));
      } else {
        emit(PromotionManagementError('Lỗi tải danh sách khuyến mãi: $e'));
      }
    }
  }

  void filterByStatus(String? filter) {
    if (state is! PromotionManagementLoaded) return;
    final currentState = state as PromotionManagementLoaded;
    final newFilter = currentState.selectedFilter == filter ? null : filter;
    final filtered = _applyFilters(
      currentState.allPromotions,
      newFilter,
      currentState.searchQuery,
    );
    emit(PromotionManagementLoaded(
      allPromotions: currentState.allPromotions,
      promotions: filtered,
      selectedFilter: newFilter,
      searchQuery: currentState.searchQuery,
    ));
  }

  void searchPromotions(String query) {
    if (state is! PromotionManagementLoaded) return;
    final currentState = state as PromotionManagementLoaded;
    final filtered = _applyFilters(
      currentState.allPromotions,
      currentState.selectedFilter,
      query,
    );
    emit(PromotionManagementLoaded(
      allPromotions: currentState.allPromotions,
      promotions: filtered,
      selectedFilter: currentState.selectedFilter,
      searchQuery: query,
    ));
  }

  List<PromotionModel> _applyFilters(
    List<PromotionModel> list,
    String? filter,
    String query,
  ) {
    final now = DateTime.now();
    final q = query.trim().toLowerCase();
    return list.where((p) {
      final matchesQuery = q.isEmpty ||
          p.code.toLowerCase().contains(q) ||
          (p.description?.toLowerCase().contains(q) ?? false);

      if (!matchesQuery) return false;

      if (filter == 'ACTIVE') {
        return p.isActive && !p.endDate.isBefore(now);
      } else if (filter == 'EXPIRED') {
        return p.endDate.isBefore(now);
      } else if (filter == 'PAUSED') {
        return !p.isActive;
      }
      return true;
    }).toList();
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
