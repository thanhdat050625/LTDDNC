import 'package:mobile_shared/mobile_shared.dart';

class CinemaManagementRepository {
  final DioClient _dioClient;

  CinemaManagementRepository(this._dioClient);

  Future<List<CinemaModel>> getAllCinemas() async {
    final response = await _dioClient.get('/cinemas', queryParameters: {'limit': 100});
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'] is List ? data['data'] : [];
    } else if (data is Map && data.containsKey('items')) {
      items = data['items'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => CinemaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CinemaModel> createCinema(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/cinemas', data: data);
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return CinemaModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<CinemaModel> updateCinema(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('/cinemas/$id', data: data);
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return CinemaModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<void> deleteCinema(int id) async {
    await _dioClient.delete('/cinemas/$id');
  }

  Future<List<RoomModel>> getRoomsByCinemaId(int cinemaId) async {
    final response = await _dioClient.get('/cinemas/$cinemaId/rooms');
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'] is List ? data['data'] : [];
    } else if (data is Map && data.containsKey('items')) {
      items = data['items'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => RoomModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RoomModel> createRoom(int cinemaId, Map<String, dynamic> data) async {
    final response = await _dioClient.post('/cinemas/$cinemaId/rooms', data: data);
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return RoomModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<RoomModel> updateRoom(int roomId, Map<String, dynamic> data) async {
    final response = await _dioClient.put('/cinemas/rooms/$roomId', data: data);
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return RoomModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<void> deleteRoom(int roomId) async {
    await _dioClient.delete('/cinemas/rooms/$roomId');
  }

  Future<List<SeatModel>> getRoomSeats(int roomId) async {
    final response = await _dioClient.get('/cinemas/rooms/$roomId/seats');
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'] is List ? data['data'] : [];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => SeatModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> generateRoomSeats(int roomId) async {
    await _dioClient.post('/cinemas/rooms/$roomId/generate-seats', data: {});
  }
}
