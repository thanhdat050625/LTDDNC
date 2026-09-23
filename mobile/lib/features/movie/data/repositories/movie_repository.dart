import 'package:cineplex_mobile/core/api/dio_client.dart';
import 'package:cineplex_mobile/features/movie/data/models/movie_model.dart';

class MovieRepository {
  final DioClient _dio;
  MovieRepository(this._dio);

  Future<({List<MovieModel> movies, int totalPages})> getAllMovies(
      int page, int pageSize, {String? genre}) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (genre != null && genre.isNotEmpty) {
      queryParams['genres'] = genre;
    }
    
    final res = await _dio.get('/movies/get-all-movies', queryParameters: queryParams);
    
    final data = res.data;
    final moviesData = data['data'] as List? ?? [];
    final movies = moviesData.map((e) => MovieModel.fromJson(e)).toList();
    
    final pagination = data['pagination'] as Map<String, dynamic>?;
    final totalPages = pagination?['totalPages'] as int? ?? 1;
    
    return (movies: movies, totalPages: totalPages);
  }

  Future<MovieModel> getMovieDetail(int id) async {
    final res = await _dio.get('/movies/get-movie/$id');
    return MovieModel.fromJson(res.data['data']);
  }
}
