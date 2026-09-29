import 'package:mobile_shared/mobile_shared.dart';

class MovieRepository {
  final DioClient _dio;
  MovieRepository(this._dio);

  Future<({List<MovieModel> movies, int totalPages})> getAllMovies(
      int page, int pageSize, {String? genre}) async {
    final response = await _dio.get('/movies/get-all-movies', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (genre != null && genre != 'All') 'genres': genre,
    });
    
    final List<dynamic> items = response.data['data'] ?? [];
    final pagination = response.data['pagination'] as Map<String, dynamic>?;
    
    return (
      movies: items.map((e) => MovieModel.fromJson(e)).toList(),
      totalPages: (pagination?['totalPages'] as int?) ?? 1,
    );
  }

  Future<MovieModel> getMovieDetail(int id) async {
    final response = await _dio.get('/movies/get-movie/$id');
    return MovieModel.fromJson(response.data['data'] ?? response.data);
  }
}
