import 'package:mobile_shared/mobile_shared.dart';

class MovieRepository {
  final DioClient _dio;
  MovieRepository(this._dio);

  Future<({List<MovieModel> movies, int totalPages})> getAllMovies(
      int page, int pageSize, {String? genre, String? search, String? status}) async {
    final response = await _dio.get('/movies/get-all-movies', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (genre != null && genre.isNotEmpty && genre != 'All' && genre != 'Tất cả') 'genres': genre,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null && status.isNotEmpty && status != 'ALL' && status != 'Tất cả') 'status': status,
    });
    
    final raw = response.data;
    final List<dynamic> items = (raw is Map && raw['data'] is List)
        ? raw['data'] as List<dynamic>
        : (raw is List ? raw : []);
    final pagination = raw is Map ? raw['pagination'] as Map<String, dynamic>? : null;
    
    return (
      movies: items.map((e) => MovieModel.fromJson(e as Map<String, dynamic>)).toList(),
      totalPages: (pagination?['totalPages'] as int?) ?? 1,
    );
  }

  Future<MovieModel> getMovieDetail(int id) async {
    final response = await _dio.get('/movies/get-movie/$id');
    final raw = response.data;
    final map = (raw is Map && raw.containsKey('data') && raw['data'] is Map<String, dynamic>)
        ? raw['data'] as Map<String, dynamic>
        : (raw as Map<String, dynamic>);
    return MovieModel.fromJson(map);
  }
}
