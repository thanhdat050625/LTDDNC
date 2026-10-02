import 'package:mobile_shared/mobile_shared.dart';

class ConcessionRepository {
  final DioClient _dioClient;

  ConcessionRepository(this._dioClient);

  Future<List<ConcessionProductModel>> getConcessions({int page = 1, int limit = 20}) async {
    final response = await _dioClient.get('/concessions', queryParameters: {'page': page, 'limit': limit});
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (data is List) {
      return data.map((e) => ConcessionProductModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
