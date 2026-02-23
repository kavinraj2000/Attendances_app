import 'package:dio/dio.dart';

class DioErrorHandler {
  static Exception handle(DioException error, String defaultMessage) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Exception('Request timed out. Please try again');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('Network error. Please check your internet connection');
    }

    if (error.type == DioExceptionType.cancel) {
      return Exception('Request was cancelled');
    }

    if (error.response?.data != null) {
      final message = _extractMessage(error.response!.data);
      if (message != null) return Exception(message);
    }

    if (error.message != null && error.message!.isNotEmpty) {
      final msg = error.message!;
      if (msg.contains('SocketException')) {
        return Exception('Network error. Please check your connection');
      }
      if (msg.contains('HandshakeException')) {
        return Exception('SSL/TLS error. Please try again');
      }
    }

    return Exception(defaultMessage);
  }

  static String? extractMessage(dynamic data) => _extractMessage(data);

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      if (data['detail'] is List) {
        final details = data['detail'] as List;
        if (details.isNotEmpty && details.first is Map) {
          return details.first['msg']?.toString();
        }
      }

      final message =
          data['message'] ??
          data['error'] ??
          data['error_message'] ??
          data['msg'];

      if (message != null) return message.toString();

      if (data['data'] is Map) {
        final inner = data['data']['message'] ?? data['data']['error'];
        if (inner != null) return inner.toString();
      }
    }

    return null;
  }
}
