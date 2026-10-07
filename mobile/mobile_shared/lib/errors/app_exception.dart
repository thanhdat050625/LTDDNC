import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);
  
  @override
  String toString() => message;
}

class ServerException extends AppException {
  final String? code;
  ServerException(super.message, {this.code});

  factory ServerException.fromDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ServerException('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng/USB.');
    }

    String msg = 'Server Error';
    String? code;
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['error'] != null && data['error'] is Map) {
          msg = data['error']['message'] ?? msg;
          code = data['error']['code']?.toString();
        } else if (data['message'] != null) {
          msg = data['message'].toString();
        }
      }
    }
    return ServerException(msg, code: code);
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
