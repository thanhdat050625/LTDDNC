import 'package:mobile_shared/mobile_shared.dart';

class HomeRepository {
  final DioClient _dio;
  HomeRepository(this._dio);

  Future<HomeDataModel> getHomeData() async {
    final response = await _dio.get('/home');
    return HomeDataModel.fromJson(response.data['data'] ?? response.data);
  }
}
