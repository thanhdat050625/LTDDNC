import 'package:cineplex_mobile/core/api/dio_client.dart';
import 'package:cineplex_mobile/features/home/data/models/home_data_model.dart';
import 'package:cineplex_mobile/features/movie/data/models/movie_model.dart';

class HomeRepository {
  final DioClient _dio;
  HomeRepository(this._dio);

  Future<HomeDataModel> getHomeData() async {
    final response = await _dio.get('/home');
    return HomeDataModel.fromJson(response.data['data'] ?? response.data);
  }
}
