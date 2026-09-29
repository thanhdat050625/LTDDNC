import 'package:cineplex_client/core/api/dio_client.dart';
import 'package:cineplex_client/core/api/api_response.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final DioClient _dioClient;

  PaymentRepository(this._dioClient);

  Future<CheckoutPrepareModel> prepareCheckout(String bookingId) async {
    final response = await _dioClient.get('/payments/prepare/$bookingId');
    final apiResponse = ApiResponse.fromJson(response.data);
    return CheckoutPrepareModel.fromJson(apiResponse.data);
  }

  Future<PaymentResponseModel> checkout(String bookingId, String method) async {
    final response = await _dioClient.post('/payments/checkout', data: {
      'bookingId': bookingId,
      'method': method,
    });
    final apiResponse = ApiResponse.fromJson(response.data);
    return PaymentResponseModel.fromJson(apiResponse.data);
  }

  Future<PaymentStatusModel> getPaymentStatus(String bookingId) async {
    final response = await _dioClient.get('/payments/status/$bookingId');
    final apiResponse = ApiResponse.fromJson(response.data);
    return PaymentStatusModel.fromJson(apiResponse.data);
  }

  Future<dynamic> checkPromotion(String code, {String? movieId}) async {
    final response = await _dioClient.post('/promotions/check-promotion', data: {
      'code': code,
      if (movieId != null) 'movieId': movieId,
    });
    final apiResponse = ApiResponse.fromJson(response.data);
    return apiResponse.data;
  }
}
