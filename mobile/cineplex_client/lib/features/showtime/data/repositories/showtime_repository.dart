import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeRepository {
  final DioClient _dioClient;

  ShowtimeRepository(this._dioClient);

  Future<Map<String, List<ShowtimeModel>>> getShowtimesByMovie(int movieId) async {
    final response = await _dioClient.get('/showtimes/by-movie/$movieId');
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    
    final Map<String, List<ShowtimeModel>> showtimes = {};
    if (data is Map<String, dynamic>) {
      data.forEach((key, value) {
        if (value is List) {
          showtimes[key] = value.map((e) => ShowtimeModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      });
    }
    
    return showtimes;
  }

  Future<Map<String, dynamic>> getShowtimeDetail(int id) async {
    final response = await _dioClient.get('/showtimes/$id');
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return (data as Map<String, dynamic>?) ?? {};
  }

  Future<List<CinemaModel>> getCinemas({int page = 1, int limit = 20}) async {
    final response = await _dioClient.get('/cinemas', queryParameters: {'page': page, 'limit': limit});
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (data is List) {
      return data.map((e) => CinemaModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<CinemaModel> getCinema(int id) async {
    final response = await _dioClient.get('/cinemas/$id');
    final raw = response.data;
    final payload = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return CinemaModel.fromJson(payload as Map<String, dynamic>);
  }
}
