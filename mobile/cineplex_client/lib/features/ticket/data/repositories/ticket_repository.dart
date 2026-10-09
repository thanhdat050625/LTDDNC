import 'package:mobile_shared/mobile_shared.dart';

class TicketRepository {
  final DioClient _dioClient;

  TicketRepository(this._dioClient);

  Future<List<BookingDetailModel>> getMyBookings({int page = 1, int pageSize = 20}) async {
    final response = await _dioClient.get('/bookings/my-bookings', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    final raw = response.data;
    final List<dynamic> list = (raw is Map && raw['data'] is List)
        ? raw['data'] as List<dynamic>
        : (raw is List ? raw : []);
    return list.map((e) => BookingDetailModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BookingDetailModel?> getBookingById(String id) async {
    final response = await _dioClient.get('/bookings/$id');
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (data is Map<String, dynamic>) {
      return BookingDetailModel.fromJson(data);
    }
    return null;
  }
}
