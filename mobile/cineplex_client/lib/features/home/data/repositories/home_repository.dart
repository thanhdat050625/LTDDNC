import 'package:cineplex_client/core/api/dio_client.dart';
import 'package:cineplex_client/features/home/data/models/home_data_model.dart';

class HomeRepository {
  final DioClient _dio;
  HomeRepository(this._dio);

  Future<HomeDataModel> getHomeData() async {
    final response = await _dio.get('/home');
    return HomeDataModel.fromJson(response.data['data'] ?? response.data);
  }
}
