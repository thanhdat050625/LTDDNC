import 'package:mobile_shared/mobile_shared.dart';

class PromotionManagementRepository {
  final DioClient _dioClient;

  PromotionManagementRepository(this._dioClient);

  Future<List<PromotionModel>> getAllPromotions() async {
    final response = await _dioClient.get('/promotions', queryParameters: {'limit': 100});
    final data = response.data;
    List<dynamic> items = [];
    if (data is Map && data.containsKey('data')) {
      items = data['data'] is List ? data['data'] : [];
    } else if (data is Map && data.containsKey('items')) {
      items = data['items'];
    } else if (data is List) {
      items = data;
    }
    return items.map((e) => PromotionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PromotionModel> createPromotion(Map<String, dynamic> data) async {
    final response = await _dioClient.post('/promotions', data: data);
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return PromotionModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<PromotionModel> updatePromotion(int id, Map<String, dynamic> data) async {
    final response = await _dioClient.put('/promotions/$id', data: data);
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return PromotionModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<void> deletePromotion(int id) async {
    await _dioClient.delete('/promotions/$id');
  }

  Future<List<PromotionModel>> getActivePromotions() async {
    final response = await _dioClient.get('/promotions/active');
    final raw = response.data;
    final payload = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (payload is List) {
      return payload
          .map((e) => PromotionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<dynamic> checkPromotion(
    String code, {
    int? movieId,
    num? orderTotal,
  }) async {
    final response = await _dioClient.post('/promotions/check-promotion', data: {
      'code': code,
      if (movieId != null) 'movieId': movieId,
      if (orderTotal != null) 'orderTotal': orderTotal,
    });
    final raw = response.data;
    return (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
  }
}
