import 'package:cineplex_mobile/core/api/dio_client.dart';
import 'package:cineplex_mobile/core/api/api_response.dart';
import 'package:cineplex_mobile/features/ticket/data/models/ticket_model.dart'; // Reuse

class StaffRepository {
  final DioClient _dioClient;

  StaffRepository(this._dioClient);

  Future<TicketModel> checkinTicket(String qrCode) async {
    final response = await _dioClient.post('/tickets/$qrCode/checkin');
    final apiResponse = ApiResponse.fromJson(response.data);
    return TicketModel.fromJson(apiResponse.data);
  }
}
