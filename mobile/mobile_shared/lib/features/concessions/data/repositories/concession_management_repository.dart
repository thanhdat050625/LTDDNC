import 'package:mobile_shared/mobile_shared.dart';

class ConcessionManagementRepository {
  final DioClient _dioClient;

  ConcessionManagementRepository(this._dioClient);

  Future<List<ConcessionProductModel>> getAllConcessions() async {
    final response = await _dioClient.get('/concessions', queryParameters: {'limit': 100});
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('items')) {
      items = data['items'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => ConcessionProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ConcessionProductModel> createConcession(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/concessions', data: data);
    return ConcessionProductModel.fromJson(response.data);
  }

  Future<ConcessionProductModel> updateConcession(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('/concessions/$id', data: data);
    return ConcessionProductModel.fromJson(response.data);
  }

  Future<void> deleteConcession(int id) async {
    await _dioClient.delete('/concessions/$id');
  }
}
