import 'package:mobile_shared/mobile_shared.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final DioClient _dioClient;

  PaymentRepository(this._dioClient);

  Future<CheckoutPrepareModel> prepareCheckout(String bookingId) async {
    final response = await _dioClient.get('/payments/prepare/$bookingId');
    final raw = response.data;
    final payload = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return CheckoutPrepareModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<PaymentResponseModel> checkout(String bookingId, String method) async {
    final response = await _dioClient.post('/payments/checkout', data: {
      'bookingId': int.tryParse(bookingId) ?? bookingId,
      'method': method,
    });
    final raw = response.data;
    final payload = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return PaymentResponseModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<PaymentStatusModel> getPaymentStatus(String bookingId) async {
    final isNum = int.tryParse(bookingId) != null;
    final endpoint = isNum ? '/payments/status/$bookingId' : '/payments/status-by-code/$bookingId';
    final response = await _dioClient.get(endpoint);
    final raw = response.data;
    final payload = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return PaymentStatusModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<CheckoutPrepareModel> prepareCheckoutDraft({
    required int showtimeId,
    required List<int> seatIds,
    List<Map<String, dynamic>> concessions = const [],
  }) async {
    final response = await _dioClient.post('/payments/prepare-draft', data: {
      'showtimeId': showtimeId,
      'seatIds': seatIds,
      'concessions': concessions,
    });
    final raw = response.data;
    final payload = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return CheckoutPrepareModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<dynamic> checkPromotion(String code, {String? movieId, num? orderTotal}) async {
    final response = await _dioClient.post('/promotions/check-promotion', data: {
      'code': code,
      if (movieId != null) 'movieId': int.tryParse(movieId) ?? movieId,
      if (orderTotal != null) 'orderTotal': orderTotal,
    });
    final raw = response.data;
    return (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
  }

  Future<Map<String, dynamic>> applyPromotion(String bookingId, String code) async {
    final response = await _dioClient.post('/bookings/$bookingId/promotion', data: {
      'code': code,
    });
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return (data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> removePromotion(String bookingId) async {
    final response = await _dioClient.delete('/bookings/$bookingId/promotion');
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return (data as Map<String, dynamic>?) ?? {};
  }

  Future<List<PromotionModel>> getActivePromotions() async {
    final response = await _dioClient.get('/promotions/active');
    final raw = response.data;
    final payload = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    if (payload is List) {
      return payload.map((e) => PromotionModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> applyLoyaltyPoints(String bookingId, int pointsToUse) async {
    final response = await _dioClient.post('/bookings/$bookingId/loyalty-points', data: {
      'pointsToUse': pointsToUse,
    });
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return (data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> removeLoyaltyPoints(String bookingId) async {
    final response = await _dioClient.delete('/bookings/$bookingId/loyalty-points');
    final raw = response.data;
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return (data as Map<String, dynamic>?) ?? {};
  }
}
