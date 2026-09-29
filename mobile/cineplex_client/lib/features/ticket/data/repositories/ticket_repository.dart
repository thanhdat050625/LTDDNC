import 'package:cineplex_client/core/api/dio_client.dart';
import 'package:cineplex_client/core/api/api_response.dart';
import 'package:cineplex_client/features/ticket/data/models/ticket_model.dart';

class TicketRepository {
  final DioClient _dioClient;

  TicketRepository(this._dioClient);

  Future<List<BookingDetailModel>> getMyBookings({int page = 1, int pageSize = 20}) async {
    final response = await _dioClient.get('/bookings/my-bookings', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    final apiResponse = ApiResponse.fromJson(response.data);
    return (apiResponse.data as List).map((e) => BookingDetailModel.fromJson(e)).toList();
  }
}
