import 'package:mobile_shared/mobile_shared.dart';

class PromotionManagementRepository {
  final DioClient _dioClient;

  PromotionManagementRepository(this._dioClient);

  Future<List<PromotionModel>> getAllPromotions() async {
    final response = await _dioClient.get('/promotions', queryParameters: {'limit': 100});
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => PromotionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PromotionModel> createPromotion(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/promotions', data: data);
    return PromotionModel.fromJson(response.data);
  }

  Future<PromotionModel> updatePromotion(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('/promotions/$id', data: data);
    return PromotionModel.fromJson(response.data);
  }

  Future<void> deletePromotion(int id) async {
    await _dioClient.delete('/promotions/$id');
  }
}
