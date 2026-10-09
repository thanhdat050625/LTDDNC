import 'package:mobile_shared/mobile_shared.dart';

class ShiftRepository {
  final DioClient _dioClient;

  ShiftRepository(this._dioClient);

  Future<List<ShiftModel>> getAllShifts() async {
    final response = await _dioClient.get('/shifts');
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'] is List ? data['data'] : [];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => ShiftModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<StaffScheduleModel>> getSchedules({
    int? cinemaId,
    int? staffId,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {};
    if (cinemaId != null) params['cinemaId'] = cinemaId;
    if (staffId != null) params['staffId'] = staffId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _dioClient.get('/shifts/schedules', queryParameters: params);
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'] is List ? data['data'] : [];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => StaffScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<StaffScheduleModel>> getMySchedule({
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _dioClient.get('/shifts/schedules/me', queryParameters: params);
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'] is List ? data['data'] : [];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => StaffScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StaffScheduleModel> createSchedule(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/shifts/schedules', data: data);
    final payload = (response.data is Map && response.data.containsKey('data'))
        ? response.data['data']
        : response.data;
    return StaffScheduleModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<StaffScheduleModel> updateSchedule(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('/shifts/schedules/$id', data: data);
    final payload = (response.data is Map && response.data.containsKey('data'))
        ? response.data['data']
        : response.data;
    return StaffScheduleModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<void> deleteSchedule(int id) async {
    await _dioClient.delete('/shifts/schedules/$id');
  }

  Future<void> bulkSyncSchedules(Map<String, dynamic> data) async {
    await _dioClient.post('/shifts/schedules/bulk', data: data);
  }
}
