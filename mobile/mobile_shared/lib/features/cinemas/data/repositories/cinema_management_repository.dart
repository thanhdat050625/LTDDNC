import 'package:mobile_shared/mobile_shared.dart';

class CinemaManagementRepository {
  final DioClient _dioClient;

  CinemaManagementRepository(this._dioClient);

  Future<List<CinemaModel>> getAllCinemas() async {
    final response = await _dioClient.get('/cinemas', queryParameters: {'limit': 100});
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('items')) {
      items = data['items'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => CinemaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CinemaModel> createCinema(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/cinemas', data: data);
    return CinemaModel.fromJson(response.data);
  }

  Future<CinemaModel> updateCinema(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('/cinemas/$id', data: data);
    return CinemaModel.fromJson(response.data);
  }

  Future<void> deleteCinema(int id) async {
    await _dioClient.delete('/cinemas/$id');
  }

  Future<List<RoomModel>> getRoomsByCinemaId(int cinemaId) async {
    final response = await _dioClient.get('/cinemas/$cinemaId/rooms');
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('items')) {
      items = data['items'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => RoomModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RoomModel> createRoom(int cinemaId, Map<String, dynamic> data) async {
    final response = await _dioClient.post('/cinemas/$cinemaId/rooms', data: data);
    return RoomModel.fromJson(response.data);
  }

  Future<RoomModel> updateRoom(int roomId, Map<String, dynamic> data) async {
    final response = await _dioClient.put('/cinemas/rooms/$roomId', data: data);
    return RoomModel.fromJson(response.data);
  }

  Future<void> deleteRoom(int roomId) async {
    await _dioClient.delete('/cinemas/rooms/$roomId');
  }
}
