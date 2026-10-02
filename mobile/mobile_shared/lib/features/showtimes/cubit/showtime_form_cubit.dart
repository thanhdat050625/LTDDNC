import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeFormCubit extends Cubit<ShowtimeFormState> {
  final ShowtimeManagementRepository _showtimeRepo;
  final MovieManagementRepository _movieRepo;
  final CinemaManagementRepository _cinemaRepo;

  List<MovieModel> _movies = [];
  List<CinemaModel> _cinemas = [];
  List<RoomModel> _rooms = [];

  ShowtimeFormCubit(this._showtimeRepo, this._movieRepo, this._cinemaRepo) : super(ShowtimeFormInitial());

  Future<void> loadDependencies({int? initialCinemaId}) async {
    try {
      emit(ShowtimeFormLoadingDeps());
      final results = await Future.wait([
        _movieRepo.getAllMovies(pageSize: 100),
        _cinemaRepo.getAllCinemas(),
      ]);
      _movies = results[0] as List<MovieModel>;
      _cinemas = results[1] as List<CinemaModel>;

      if (initialCinemaId != null) {
        _rooms = await _cinemaRepo.getRoomsByCinemaId(initialCinemaId);
      }

      emit(ShowtimeFormDepsLoaded(
        movies: _movies,
        cinemas: _cinemas,
        rooms: _rooms,
        selectedCinemaId: initialCinemaId,
      ));
    } catch (e) {
      emit(ShowtimeFormError('Lỗi tải dữ liệu: $e'));
    }
  }

  Future<void> selectCinema(int cinemaId) async {
    try {
      // Keep old rooms while loading if we want, but better emit loading rooms or just wait
      // For simplicity, just fetch and re-emit
      final rooms = await _cinemaRepo.getRoomsByCinemaId(cinemaId);
      _rooms = rooms;
      emit(ShowtimeFormDepsLoaded(
        movies: _movies,
        cinemas: _cinemas,
        rooms: _rooms,
        selectedCinemaId: cinemaId,
      ));
    } catch (e) {
      emit(ShowtimeFormError('Lỗi tải danh sách phòng: $e'));
    }
  }

  Future<void> submit({
    required bool isEdit,
    int? showtimeId,
    required Map<String, dynamic> data,
  }) async {
    try {
      emit(ShowtimeFormSubmitting());
      ShowtimeModel result;
      if (isEdit && showtimeId != null) {
        result = await _showtimeRepo.updateShowtime(showtimeId, data);
      } else {
        result = await _showtimeRepo.createShowtime(data);
      }
      emit(ShowtimeFormSuccess(result));
    } catch (e) {
      if (e is ServerException) {
        emit(ShowtimeFormError(e.message));
      } else {
        emit(ShowtimeFormError('Đã xảy ra lỗi khi lưu suất chiếu: $e'));
      }
    }
  }

  Future<void> deleteShowtime(int id) async {
    try {
      emit(ShowtimeFormSubmitting());
      await _showtimeRepo.deleteShowtime(id);
      emit(const ShowtimeFormSuccess());
    } catch (e) {
      if (e is ServerException) {
        emit(ShowtimeFormError(e.message));
      } else {
        emit(ShowtimeFormError('Lỗi xóa suất chiếu: $e'));
      }
    }
  }
}
