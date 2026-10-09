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
    String filterType = 'year',
    int? year,
    int? month,
    String? startDate,
    String? endDate,
  }) async {
    final queryParameters = <String, dynamic>{
      'filterType': filterType,
      'timeFrame': filterType,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
    final response = await _dioClient.get('/statistics/revenue', queryParameters: queryParameters);
    final apiResponse = ApiResponse.fromJson(response.data);
    return (apiResponse.data as List).map((e) => RevenuePeriodModel.fromJson(e)).toList();
  }

  Future<List<MoviePerformanceModel>> getMoviePerformance({
    String filterType = 'year',
    int? year,
    int? month,
    String? startDate,
    String? endDate,
  }) async {
    final queryParameters = <String, dynamic>{
      'filterType': filterType,
      'timeFrame': filterType,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
    final response = await _dioClient.get('/statistics/movies', queryParameters: queryParameters);
    final apiResponse = ApiResponse.fromJson(response.data);
    return (apiResponse.data as List).map((e) => MoviePerformanceModel.fromJson(e)).toList();
  }
}
