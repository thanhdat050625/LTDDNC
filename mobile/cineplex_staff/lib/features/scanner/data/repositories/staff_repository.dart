import 'package:mobile_shared/mobile_shared.dart';

class StaffRepository {
  final DioClient _dioClient;

  StaffRepository(this._dioClient);

  Future<TicketModel> checkinTicket(String qrCode) async {
    final response = await _dioClient.post('/tickets/$qrCode/checkin');
    return TicketModel.fromJson(response.data);
  }
}
