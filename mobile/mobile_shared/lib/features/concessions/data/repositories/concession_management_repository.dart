import 'package:dio/dio.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ConcessionManagementRepository {
  final DioClient _dioClient;

  ConcessionManagementRepository(this._dioClient);

  Future<List<ConcessionProductModel>> getAllConcessions() async {
    final response = await _dioClient.get('/concessions', queryParameters: {'limit': 100});
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'] is List ? data['data'] : [];
    } else if (data is Map && data.containsKey('items')) {
      items = data['items'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => ConcessionProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ConcessionProductModel> createConcession(Map<String, dynamic> data, {String? imageFilePath}) async {
    dynamic postData = data;
    if (imageFilePath != null && imageFilePath.isNotEmpty) {
      final formDataMap = Map<String, dynamic>.from(data);
      final fileName = imageFilePath.split(RegExp(r'[\\/]')).last;
      formDataMap['image'] = await MultipartFile.fromFile(imageFilePath, filename: fileName);
      postData = FormData.fromMap(formDataMap);
    }
    final response = await _dioClient.post('/concessions', data: postData);
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return ConcessionProductModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<ConcessionProductModel> updateConcession(int id, Map<String, dynamic> data, {String? imageFilePath}) async {
    dynamic postData = data;
    if (imageFilePath != null && imageFilePath.isNotEmpty) {
      final formDataMap = Map<String, dynamic>.from(data);
      final fileName = imageFilePath.split(RegExp(r'[\\/]')).last;
      formDataMap['image'] = await MultipartFile.fromFile(imageFilePath, filename: fileName);
      postData = FormData.fromMap(formDataMap);
    }
    final response = await _dioClient.put('/concessions/$id', data: postData);
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return ConcessionProductModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<void> deleteConcession(int id) async {
    await _dioClient.delete('/concessions/$id');
  }
}
