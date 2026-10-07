import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeBulkCreateCubit extends Cubit<ShowtimeBulkCreateState> {
  final ShowtimeManagementRepository _showtimeRepo;
  final MovieManagementRepository _movieRepo;
  final CinemaManagementRepository _cinemaRepo;

  List<MovieModel> _movies = [];
  List<CinemaModel> _cinemas = [];
  List<RoomModel> _rooms = [];

  ShowtimeBulkCreateCubit(
    this._showtimeRepo,
    this._movieRepo,
    this._cinemaRepo,
  ) : super(ShowtimeBulkCreateInitial());

  Future<void> loadDependencies({int? initialCinemaId}) async {
    try {
      emit(ShowtimeBulkCreateLoadingDeps());
      final results = await Future.wait([
        _movieRepo.getAllMovies(pageSize: 100),
        _cinemaRepo.getAllCinemas(),
      ]);
      _movies = results[0] as List<MovieModel>;
      _cinemas = results[1] as List<CinemaModel>;

      if (initialCinemaId != null) {
        _rooms = await _cinemaRepo.getRoomsByCinemaId(initialCinemaId);
      } else {
        _rooms = [];
      }

      emit(ShowtimeBulkCreateDepsLoaded(
        movies: _movies,
        cinemas: _cinemas,
        rooms: _rooms,
        selectedCinemaId: initialCinemaId,
      ));
    } catch (e) {
      emit(ShowtimeBulkCreateError('Lỗi tải dữ liệu: $e'));
    }
  }

  Future<void> selectCinema(int cinemaId) async {
    final currentState = state;
    if (currentState is ShowtimeBulkCreateDepsLoaded) {
      emit(currentState.copyWith(
        selectedCinemaId: cinemaId,
        isLoadingRooms: true,
      ));
    }

    try {
      final rooms = await _cinemaRepo.getRoomsByCinemaId(cinemaId);
      _rooms = rooms;
      emit(ShowtimeBulkCreateDepsLoaded(
        movies: _movies,
        cinemas: _cinemas,
        rooms: _rooms,
        selectedCinemaId: cinemaId,
        isLoadingRooms: false,
      ));
    } catch (e) {
      emit(ShowtimeBulkCreateError('Lỗi tải danh sách phòng: $e'));
    }
  }

  Future<void> submit(Map<String, dynamic> payload) async {
    try {
      emit(ShowtimeBulkCreateSubmitting());
      final result = await _showtimeRepo.bulkCreateShowtime(payload);
      emit(ShowtimeBulkCreateSuccess(result));
    } catch (e) {
      if (e is ServerException) {
        emit(ShowtimeBulkCreateError(e.message));
      } else {
        emit(ShowtimeBulkCreateError('Đã xảy ra lỗi khi tạo lịch hàng loạt: $e'));
      }
    }
  }
}
