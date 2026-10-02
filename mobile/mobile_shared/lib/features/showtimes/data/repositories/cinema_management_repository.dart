import 'package:mobile_shared/mobile_shared.dart';

class CinemaManagementRepository {
  final DioClient _dioClient;

  CinemaManagementRepository(this._dioClient);

  Future<List<CinemaModel>> getAllCinemas() async {
    final response = await _dioClient.get('/cinemas', queryParameters: {'limit': 100});
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => CinemaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<RoomModel>> getRoomsByCinemaId(int cinemaId) async {
    final response = await _dioClient.get('/cinemas/$cinemaId/rooms');
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => RoomModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
