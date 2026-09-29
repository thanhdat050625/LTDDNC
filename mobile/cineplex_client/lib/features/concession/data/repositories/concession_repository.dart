import 'package:mobile_shared/mobile_shared.dart';

class ConcessionRepository {
  final DioClient _dioClient;

  ConcessionRepository(this._dioClient);

  Future<List<ConcessionProductModel>> getConcessions({int page = 1, int limit = 20}) async {
    final response = await _dioClient.get('/concessions', queryParameters: {'page': page, 'limit': limit});
    final data = response.data['data'] as List;
    return data.map((e) => ConcessionProductModel.fromJson(e)).toList();
  }
}
