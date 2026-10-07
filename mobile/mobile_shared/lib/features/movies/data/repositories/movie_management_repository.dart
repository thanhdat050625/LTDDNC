import 'package:dio/dio.dart';
import 'package:mobile_shared/mobile_shared.dart';

class MovieManagementRepository {
  final DioClient _dioClient;

  MovieManagementRepository(this._dioClient);

  Future<List<MovieModel>> getAllMovies({
    int page = 1,
    int pageSize = 50,
    String sortBy = 'id',
    List<String> genres = const [],
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy,
    };
    if (genres.isNotEmpty) {
      queryParams['genres'] = genres.join(',');
    }

    final response = await _dioClient.get('/movies/get-all-movies', queryParameters: queryParams);
    
    final data = response.data;
    List<dynamic> items = [];
    
    if (data is Map && data.containsKey('data')) {
      items = data['data'] is List ? data['data'] : [];
    } else if (data is Map && data.containsKey('items')) {
      items = data['items'];
    } else if (data is List) {
      items = data;
    }

    return items.map((e) => MovieModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MovieModel> createMovie(Map<String, dynamic> data, String? posterPath) async {
    final formData = FormData.fromMap(data);
    if (posterPath != null) {
      formData.files.add(MapEntry(
        'poster',
        await MultipartFile.fromFile(posterPath),
      ));
    }

    final response = await _dioClient.post('/movies/create-movie', data: formData);
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return MovieModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<MovieModel> updateMovie(int id, Map<String, dynamic> data, String? posterPath) async {
    final formData = FormData.fromMap(data);
    if (posterPath != null) {
      formData.files.add(MapEntry(
        'poster',
        await MultipartFile.fromFile(posterPath),
      ));
    }

    final response = await _dioClient.put('/movies/update-movie/$id', data: formData);
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return MovieModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<MovieModel> getMovieDetail(int id) async {
    final response = await _dioClient.get('/movies/get-movie/$id');
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return MovieModel.fromJson(payload as Map<String, dynamic>);
  }
}
