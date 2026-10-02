import 'package:mobile_shared/mobile_shared.dart';

class ShowtimeManagementRepository {
  final DioClient _dioClient;

  ShowtimeManagementRepository(this._dioClient);

  Future<List<ShowtimeModel>> getAllShowtimes({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dioClient.get(
      '/showtimes',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('items')) {
      items = data['items'];
    } else if (data is List) {
      items = data;
    }
    
    return items.map((e) => ShowtimeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ShowtimeModel>> getByMovieId(int movieId) async {
    final response = await _dioClient.get('/showtimes/by-movie/$movieId');
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('items')) {
      items = data['items'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => ShowtimeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ShowtimeModel> createShowtime(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/showtimes', data: data);
    return ShowtimeModel.fromJson(response.data);
  }

  Future<ShowtimeModel> updateShowtime(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('/showtimes/$id', data: data);
    return ShowtimeModel.fromJson(response.data);
  }

  Future<Map<String, dynamic>> bulkCreateShowtime(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/showtimes/bulk', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteShowtime(int id) async {
    await _dioClient.delete('/showtimes/$id');
  }
}
