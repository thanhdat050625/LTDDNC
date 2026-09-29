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

  const MovieListLoaded(this.movies, this.hasMore, this.currentPage, {this.genre});

  @override
  List<Object?> get props => [movies, hasMore, currentPage, genre];
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
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isFetching = false;
  List<MovieModel> _movies = [];

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
    _currentGenre = genre;
    await loadMovies();
  }

  Future<void> _fetchMovies() async {
    _isFetching = true;
    try {
      final result = await repository.getAllMovies(_currentPage, _pageSize, genre: _currentGenre);
      _movies.addAll(result.movies);
      final hasMore = _currentPage < result.totalPages;
      emit(MovieListLoaded(List.from(_movies), hasMore, _currentPage, genre: _currentGenre));
    } catch (e) {
      emit(MovieListError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }
}
