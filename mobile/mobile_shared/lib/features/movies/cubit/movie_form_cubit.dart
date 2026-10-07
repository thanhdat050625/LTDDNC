import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:equatable/equatable.dart';

abstract class MovieFormState extends Equatable {
  const MovieFormState();
  @override
  List<Object?> get props => [];
}

class MovieFormInitial extends MovieFormState {}

class MovieFormSubmitting extends MovieFormState {}

class MovieFormSuccess extends MovieFormState {
  final MovieModel movie;
  const MovieFormSuccess(this.movie);
  @override
  List<Object?> get props => [movie];
}

class MovieFormError extends MovieFormState {
  final String message;
  const MovieFormError(this.message);
  @override
  List<Object?> get props => [message];
}

class MovieFormCubit extends Cubit<MovieFormState> {
  final MovieManagementRepository _repository;

  MovieFormCubit(this._repository) : super(MovieFormInitial());

  Future<void> submit({
    required bool isEdit,
    int? movieId,
    required Map<String, dynamic> data,
    String? posterPath,
  }) async {
    try {
      emit(MovieFormSubmitting());
      MovieModel result;
      if (isEdit && movieId != null) {
        result = await _repository.updateMovie(movieId, data, posterPath);
      } else {
        result = await _repository.createMovie(data, posterPath);
      }
      emit(MovieFormSuccess(result));
    } catch (e) {
      if (e is ServerException) {
        emit(MovieFormError(e.message));
      } else {
        emit(MovieFormError('Đã xảy ra lỗi khi lưu phim: $e'));
      }
    }
  }
}
