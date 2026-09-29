import 'package:mobile_shared/mobile_shared.dart';

class StatisticsRepository {
  final DioClient _dioClient;

  StatisticsRepository(this._dioClient);

  Future<SummaryModel> getSummary() async {
    final response = await _dioClient.get('/statistics/summary');
    final apiResponse = ApiResponse.fromJson(response.data);
    return SummaryModel.fromJson(apiResponse.data);
  }

  Future<List<RevenuePeriodModel>> getRevenueStatistics({
    String timeFrame = 'month',
    int? year,
    int? month,
  }) async {
    final queryParameters = <String, dynamic>{
      'timeFrame': timeFrame,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
    };
    final response = await _dioClient.get('/statistics/revenue', queryParameters: queryParameters);
    final apiResponse = ApiResponse.fromJson(response.data);
    return (apiResponse.data as List).map((e) => RevenuePeriodModel.fromJson(e)).toList();
  }

  Future<List<MoviePerformanceModel>> getMoviePerformance() async {
    final response = await _dioClient.get('/statistics/movies');
    final apiResponse = ApiResponse.fromJson(response.data);
    return (apiResponse.data as List).map((e) => MoviePerformanceModel.fromJson(e)).toList();
  }
}
