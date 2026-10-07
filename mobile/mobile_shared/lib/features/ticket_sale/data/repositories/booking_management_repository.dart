import 'package:mobile_shared/mobile_shared.dart';

class BookingManagementRepository {
  final DioClient _dioClient;

  BookingManagementRepository(this._dioClient);

  Future<List<SeatModel>> getShowtimeSeats(int showtimeId) async {
    final response = await _dioClient.get('/showtimes/$showtimeId');
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (data is Map<String, dynamic>) {
      final seats = data['seats'];
      if (seats is List) {
        return seats
            .map((e) => SeatModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<bool> holdSeats(int showtimeId, List<int> seatIds) async {
    final response = await _dioClient.post(
      '/bookings/staff/hold-seats',
      data: {'showtimeId': showtimeId, 'seatIds': seatIds},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<BookingModel> createStaffBooking(
    int showtimeId,
    List<int> seatIds, {
    int? customerId,
    List<Map<String, dynamic>>? concessions,
    int? pointsToUse,
    String source = 'OFFLINE',
  }) async {
    final response = await _dioClient.post(
      '/bookings/staff',
      data: {
        'showtimeId': showtimeId,
        'seatIds': seatIds,
        'source': source,
        if (customerId != null) 'customerId': customerId,
        if (concessions != null && concessions.isNotEmpty)
          'concessions': concessions,
        if (pointsToUse != null && pointsToUse > 0) 'pointsToUse': pointsToUse,
      },
    );
    final payload = (response.data is Map && response.data.containsKey('data'))
        ? response.data['data']
        : response.data;
    return BookingModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<dynamic> checkoutPayment({
    required int bookingId,
    required String method,
  }) async {
    final response = await _dioClient.post(
      '/payments/checkout',
      data: {'bookingId': bookingId, 'method': method},
    );
    return (response.data is Map && response.data.containsKey('data'))
        ? response.data['data']
        : response.data;
  }

  Future<Map<String, dynamic>> getPaymentStatus(int bookingId) async {
    final response = await _dioClient.get('/payments/status/$bookingId');
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  Future<List<UserModel>> searchCustomers(String keyword) async {
    final response = await _dioClient.get(
      '/users/search',
      queryParameters: {'keyword': keyword},
    );
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (data is List) {
      return data
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> confirmBooking(int bookingId, String paymentMethod) async {
    await _dioClient.post(
      '/bookings/$bookingId/confirm',
      data: {'paymentMethod': paymentMethod},
    );
  }

  Future<void> updateConcessions(
    int bookingId,
    List<Map<String, dynamic>> items,
  ) async {
    await _dioClient.put(
      '/bookings/$bookingId/concessions',
      data: {'items': items},
    );
  }

  Future<List<BookingDetailModel>> getAllBookings({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dioClient.get(
      '/bookings',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (data is List) {
      return data
          .map((e) => BookingDetailModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<TicketPriceModel>> getTicketPrices() async {
    final response = await _dioClient.get('/tickets/prices');
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (data is List) {
      return data
          .map((e) => TicketPriceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> updateTicketPrice(int id, num price) async {
    await _dioClient.put('/tickets/prices/$id', data: {'price': price});
  }
}
