import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/repositories/movie_repository.dart';

abstract class MovieListState extends Equatable {
  const MovieListState();
  @override
  List<Object?> get props => [];
}

class MovieListInitial extends MovieListState {}
class MovieListLoading extends MovieListState {}
class MovieListLoaded extends MovieListState {
  final List<MovieModel> movies;
  final bool hasMore;
  final int currentPage;
  final String? genre;
  final String? status;
  final String? searchQuery;

  const MovieListLoaded(
    this.movies,
    this.hasMore,
    this.currentPage, {
    this.genre,
    this.status,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [movies, hasMore, currentPage, genre, status, searchQuery];
}
class MovieListError extends MovieListState {
  final String message;
  const MovieListError(this.message);
  @override
  List<Object> get props => [message];
}

class MovieListCubit extends Cubit<MovieListState> {
  final MovieRepository repository;
  MovieListCubit(this.repository) : super(MovieListInitial());

  String? _currentGenre;
  String? _currentStatus;
  String? _searchQuery;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isFetching = false;
  List<MovieModel> _movies = [];

  String? get currentGenre => _currentGenre;
  String? get currentStatus => _currentStatus;
  String? get searchQuery => _searchQuery;

  Future<void> loadMovies() async {
    _currentPage = 1;
    _movies = [];
    emit(MovieListLoading());
    await _fetchMovies();
  }

  Future<void> loadMore() async {
    if (_isFetching || state is! MovieListLoaded) return;
    final currentState = state as MovieListLoaded;
    if (!currentState.hasMore) return;

    _currentPage++;
    await _fetchMovies();
  }

  Future<void> filterByGenre(String? genre) async {
    _currentGenre = (genre == null || genre == 'All') ? null : genre;
    await loadMovies();
  }

  Future<void> filterByStatus(String? status) async {
    _currentStatus = (status == null || status == 'ALL') ? null : status;
    await loadMovies();
  }

  Future<void> searchMovies(String query) async {
    final trimmed = query.trim();
    _searchQuery = trimmed.isEmpty ? null : trimmed;
    await loadMovies();
  }

  Future<void> clearSearch() async {
    _searchQuery = null;
    await loadMovies();
  }

  Future<void> _fetchMovies() async {
    _isFetching = true;
    try {
      final result = await repository.getAllMovies(
        _currentPage,
        _pageSize,
        genre: _currentGenre,
        status: _currentStatus,
        search: _searchQuery,
      );
      _movies.addAll(result.movies);
      final hasMore = _currentPage < result.totalPages;
      emit(MovieListLoaded(
        List.from(_movies),
        hasMore,
        _currentPage,
        genre: _currentGenre,
        status: _currentStatus,
        searchQuery: _searchQuery,
      ));
    } catch (e) {
      emit(MovieListError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }
}
