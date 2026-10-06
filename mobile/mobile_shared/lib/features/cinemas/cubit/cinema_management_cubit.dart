import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class CinemaManagementCubit extends Cubit<CinemaManagementState> {
  final CinemaManagementRepository _repository;
  List<CinemaModel> _allCinemas = [];
  String? _selectedStatus;

  CinemaManagementCubit(this._repository) : super(CinemaManagementInitial());

  Future<void> loadCinemas() async {
    try {
      emit(CinemaManagementLoading());
      final cinemas = await _repository.getAllCinemas();
      _allCinemas = cinemas;
      _applyFilters();
    } catch (e) {
      if (e is ServerException) {
        emit(CinemaManagementError(e.message));
      } else {
        emit(CinemaManagementError('Lỗi tải danh sách rạp: $e'));
      }
    }
  }

  // ponytail: In-memory cinema filtering; upgrade to paginated query params if cinemas exceed 100.
  void filterByStatus(String? status) {
    if (status == null || _selectedStatus == status) {
      _selectedStatus = null;
    } else {
      _selectedStatus = status;
    }
    if (state is CinemaManagementLoaded) {
      _applyFilters();
    }
  }

  void _applyFilters() {
    var filtered = _allCinemas;
    if (_selectedStatus != null) {
      filtered = filtered
          .where((c) => c.status.toUpperCase() == _selectedStatus!.toUpperCase())
          .toList();
    }
    emit(CinemaManagementLoaded(
      cinemas: filtered,
      allCinemas: _allCinemas,
      selectedStatus: _selectedStatus,
    ));
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
