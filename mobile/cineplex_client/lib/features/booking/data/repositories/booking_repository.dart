import 'package:mobile_shared/mobile_shared.dart';

class BookingRepository {
  final DioClient _dioClient;

  BookingRepository(this._dioClient);

  Future<Map<String, dynamic>> holdSeats(int showtimeId, List<int> seatIds) async {
    final response = await _dioClient.post('/bookings/hold-seats', data: {
      'showtimeId': showtimeId,
      'seatIds': seatIds,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<BookingModel> createBooking(CreateBookingDto dto) async {
    final response = await _dioClient.post('/bookings', data: dto.toJson());
    return BookingModel.fromJson(response.data['data']);
  }

  Future<List<BookingModel>> getMyBookings({int page = 1, int limit = 20}) async {
    final response = await _dioClient.get('/bookings', queryParameters: {'page': page, 'limit': limit});
    final data = response.data['data'] as List;
    return data.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getUnavailableSeats(int showtimeId) async {
    final response = await _dioClient.get('/bookings/showtime/$showtimeId/seats');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateBookingConcessions(int bookingId, UpdateBookingConcessionsDto dto) async {
    final response = await _dioClient.put('/bookings/$bookingId/concessions', data: dto.toJson());
    return response.data['data'] as Map<String, dynamic>;
  }
}
