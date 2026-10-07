import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MovieManagementCubit extends Cubit<MovieManagementState> {
  final MovieManagementRepository _repository;
  List<MovieModel> _allMovies = [];
  String _searchQuery = '';
  String? _selectedStatus;

  MovieManagementCubit(this._repository) : super(MovieManagementInitial());

  Future<void> loadMovies() async {
    try {
      emit(MovieManagementLoading());
      final movies = await _repository.getAllMovies();
      _allMovies = movies;
      _emitFiltered();
    } catch (e) {
      if (e is ServerException) {
        emit(MovieManagementError(e.message));
      } else {
        emit(MovieManagementError('Lỗi tải dữ liệu phim: $e'));
      }
    }
  }

  void searchMovies(String query) {
    _searchQuery = query;
    _emitFiltered();
  }

  // ponytail: In-memory movie filtering; upgrade to paginated server-side filters if movie list exceeds 200 items.
  void filterByStatus(String? status) {
    if (status == null || _selectedStatus == status) {
      _selectedStatus = null;
    } else {
      _selectedStatus = status;
    }
    _emitFiltered();
  }

  void _emitFiltered() {
    var filtered = _allMovies;
    if (_searchQuery.trim().isNotEmpty) {
      filtered = filtered
          .where((m) => m.title.toLowerCase().contains(_searchQuery.trim().toLowerCase()))
          .toList();
    }
    if (_selectedStatus != null) {
      filtered = filtered
          .where((m) => m.status.toUpperCase() == _selectedStatus!.toUpperCase())
          .toList();
    }
    emit(MovieManagementLoaded(
      movies: filtered,
      allMovies: _allMovies,
      selectedStatus: _selectedStatus,
      isSearching: _searchQuery.isNotEmpty,
    ));
  }
}
