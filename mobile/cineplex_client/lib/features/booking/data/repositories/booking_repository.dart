import 'package:mobile_shared/mobile_shared.dart';

class BookingRepository {
  final DioClient _dioClient;

  BookingRepository(this._dioClient);

  Future<Map<String, dynamic>> holdSeats(int showtimeId, List<int> seatIds) async {
    final response = await _dioClient.post('/bookings/hold-seats', data: {
      'showtimeId': showtimeId,
      'seatIds': seatIds,
    });
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return (data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> releaseSeats(int showtimeId, List<int> seatIds) async {
    final response = await _dioClient.post('/bookings/release-seats', data: {
      'showtimeId': showtimeId,
      'seatIds': seatIds,
    });
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return (data as Map<String, dynamic>?) ?? {};
  }

  Future<BookingModel> createBooking(CreateBookingDto dto) async {
    final response = await _dioClient.post('/bookings', data: dto.toJson());
    final raw = response.data;
    final payload = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return BookingModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<List<BookingModel>> getMyBookings({int page = 1, int limit = 20}) async {
    final response = await _dioClient.get('/bookings', queryParameters: {'page': page, 'limit': limit});
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (data is List) {
      return data.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getUnavailableSeats(int showtimeId) async {
    final response = await _dioClient.get('/bookings/showtime/$showtimeId/seats');
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return (data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> updateBookingConcessions(int bookingId, UpdateBookingConcessionsDto dto) async {
    final response = await _dioClient.put('/bookings/$bookingId/concessions', data: dto.toJson());
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return (data as Map<String, dynamic>?) ?? {};
  }
}
