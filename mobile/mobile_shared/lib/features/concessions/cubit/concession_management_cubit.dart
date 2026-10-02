import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ConcessionManagementCubit extends Cubit<ConcessionManagementState> {
  final ConcessionManagementRepository _repository;

  ConcessionManagementCubit(this._repository) : super(ConcessionManagementInitial());

  Future<void> loadConcessions() async {
    try {
      emit(ConcessionManagementLoading());
      final concessions = await _repository.getAllConcessions();
      int lowStock = 0;
      int outOfStock = 0;
      for (var c in concessions) {
        if (c.stockQuantity == 0) outOfStock++;
        else if (c.stockQuantity <= 5) lowStock++;
      }
      final summary = {
        'total': concessions.length,
        'lowStock': lowStock,
        'outOfStock': outOfStock,
      };
      emit(ConcessionManagementLoaded(concessions, summary));
    } catch (e) {
      if (e is ServerException) {
        emit(ConcessionManagementError(e.message));
      } else {
        emit(ConcessionManagementError('Lỗi tải danh sách bắp nước: $e'));
      }
    }
  }

  Future<void> deleteConcession(int id) async {
    try {
      await _repository.deleteConcession(id);
      loadConcessions();
    } catch (e) {
      if (e is ServerException) {
        emit(ConcessionManagementError(e.message));
      } else {
        emit(ConcessionManagementError('Lỗi xóa bắp nước: $e'));
      }
    }
  }
}
