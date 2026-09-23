import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);
  
  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException(super.message);

  factory ServerException.fromDioError(DioException e) {
    String msg = 'Server Error';
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['error'] != null) {
        msg = data['error']['message'] ?? msg;
      }
    }
    return ServerException(msg);
  }
}

class NetworkException extends AppException {
  NetworkException([String message = 'No internet connection']) : super(message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Unauthorized']) : super(message);
}

class CacheException extends AppException {
  CacheException([String message = 'Cache error']) : super(message);
}
