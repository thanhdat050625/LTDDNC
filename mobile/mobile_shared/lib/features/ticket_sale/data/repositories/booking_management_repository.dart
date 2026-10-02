import 'package:mobile_shared/mobile_shared.dart';

class BookingManagementRepository {
  final DioClient _dioClient;

  BookingManagementRepository(this._dioClient);

  Future<List<SeatModel>> getShowtimeSeats(int showtimeId) async {
    final response = await _dioClient.get('/bookings/showtime/$showtimeId/seats');
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (data is List) {
      return data.map((e) => SeatModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<bool> holdSeats(int showtimeId, List<int> seatIds) async {
    final response = await _dioClient.post('/bookings/staff/hold-seats', data: {
      'showtimeId': showtimeId,
      'seatIds': seatIds,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<BookingModel> createStaffBooking(int showtimeId, List<int> seatIds, {int? customerId}) async {
    final response = await _dioClient.post('/bookings/staff', data: {
      'showtimeId': showtimeId,
      'seatIds': seatIds,
      if (customerId != null) 'customerId': customerId,
    });
    final payload = (response.data is Map && response.data.containsKey('data')) ? response.data['data'] : response.data;
    return BookingModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<void> confirmBooking(int bookingId, String paymentMethod) async {
    await _dioClient.post('/bookings/$bookingId/confirm', data: {
      'paymentMethod': paymentMethod,
    });
  }

  Future<void> updateConcessions(int bookingId, List<Map<String, dynamic>> items) async {
    await _dioClient.put('/bookings/$bookingId/concessions', data: {
      'items': items,
    });
  }
}
