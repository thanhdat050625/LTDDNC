import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../data/repositories/movie_repository.dart';

abstract class MovieDetailState extends Equatable {
  const MovieDetailState();
  @override
  List<Object> get props => [];
}

class MovieDetailInitial extends MovieDetailState {}
class MovieDetailLoading extends MovieDetailState {}
class MovieDetailLoaded extends MovieDetailState {
  final MovieModel movie;
  const MovieDetailLoaded(this.movie);
  @override
  List<Object> get props => [movie];
}
class MovieDetailError extends MovieDetailState {
  final String message;
  const MovieDetailError(this.message);
  @override
  List<Object> get props => [message];
}

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final MovieRepository repository;
  MovieDetailCubit(this.repository) : super(MovieDetailInitial());
  
  Future<void> loadMovie(int movieId) async {
    emit(MovieDetailLoading());
    try {
      final movie = await repository.getMovieDetail(movieId);
      emit(MovieDetailLoaded(movie));
    } catch (e) {
      emit(MovieDetailError(e.toString()));
    }
  }
}
