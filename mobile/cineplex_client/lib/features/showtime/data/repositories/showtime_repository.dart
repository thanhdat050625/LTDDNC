import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeRepository {
  final DioClient _dioClient;

  ShowtimeRepository(this._dioClient);

  Future<Map<String, List<ShowtimeModel>>> getShowtimesByMovie(int movieId) async {
    final response = await _dioClient.get('/showtimes/by-movie/$movieId');
    final data = response.data['data'] as Map<String, dynamic>;
    
    final Map<String, List<ShowtimeModel>> showtimes = {};
    data.forEach((key, value) {
      showtimes[key] = (value as List).map((e) => ShowtimeModel.fromJson(e)).toList();
    });
    
    return showtimes;
  }

  Future<Map<String, dynamic>> getShowtimeDetail(int id) async {
    final response = await _dioClient.get('/showtimes/$id');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<CinemaModel>> getCinemas({int page = 1, int limit = 20}) async {
    final response = await _dioClient.get('/cinemas', queryParameters: {'page': page, 'limit': limit});
    final data = response.data['data'] as List;
    return data.map((e) => CinemaModel.fromJson(e)).toList();
  }

  Future<CinemaModel> getCinema(int id) async {
    final response = await _dioClient.get('/cinemas/$id');
    return CinemaModel.fromJson(response.data['data']);
  }
}
