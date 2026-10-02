import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MovieManagementCubit extends Cubit<MovieManagementState> {
  final MovieManagementRepository _repository;
  List<MovieModel> _allMovies = [];

  MovieManagementCubit(this._repository) : super(MovieManagementInitial());

  Future<void> loadMovies() async {
    try {
      emit(MovieManagementLoading());
      final movies = await _repository.getAllMovies();
      _allMovies = movies;
      emit(MovieManagementLoaded(movies: movies));
    } catch (e) {
      if (e is ServerException) {
        emit(MovieManagementError(e.message));
      } else {
        emit(MovieManagementError('Lỗi tải dữ liệu phim: $e'));
      }
    }
  }

  void searchMovies(String query) {
    if (state is MovieManagementLoaded) {
      if (query.isEmpty) {
        emit(MovieManagementLoaded(movies: _allMovies, isSearching: false));
        return;
      }
      
      final filtered = _allMovies.where((m) => m.title.toLowerCase().contains(query.toLowerCase())).toList();
      emit(MovieManagementLoaded(movies: filtered, isSearching: true));
    }
  }
}
