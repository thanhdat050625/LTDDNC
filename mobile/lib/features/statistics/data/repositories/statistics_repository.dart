import 'package:cineplex_mobile/core/api/dio_client.dart';
import 'package:cineplex_mobile/core/api/api_response.dart';
import '../models/statistics_model.dart';

class StatisticsRepository {
  final DioClient _dioClient;

  StatisticsRepository(this._dioClient);

  Future<SummaryModel> getSummary() async {
    final response = await _dioClient.get('/statistics/summary');
    final apiResponse = ApiResponse.fromJson(response.data);
    return SummaryModel.fromJson(apiResponse.data);
  }
}
