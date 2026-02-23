import 'package:hrm/core/util/error_handler.dart';

class ResponseHandler {
  ResponseHandler._();

  static T handle<T>({
    required int? statusCode,
    required dynamic data,
    required T Function(dynamic data) onSuccess,
    String defaultError = 'Something went wrong',
  }) {
    switch (statusCode) {
      case 200:
      case 201:
        return onSuccess(data);

      case 400:
        throw Exception(DioErrorHandler.extractMessage(data) ?? 'Bad request');

      case 401:
      case 403:
        throw Exception('Session expired. Please login again');

      case 404:
        throw Exception(
          DioErrorHandler.extractMessage(data) ?? 'Resource not found',
        );

      case 409:
        throw Exception(
          DioErrorHandler.extractMessage(data) ?? 'Conflict error',
        );

      case 500:
        throw Exception(
          DioErrorHandler.extractMessage(data) ??
              'Server error. Please try again.',
        );

      default:
        throw Exception(
          DioErrorHandler.extractMessage(data) ??
              '$defaultError (status: $statusCode)',
        );
    }
  }

  static List<T> handleList<T>({
    required int? statusCode,
    required dynamic data,
    required T Function(dynamic item) fromJson,
    String listKey = 'data',
  }) {
    if (statusCode != 200 && statusCode != 201) return [];

    if (data == null || data is! Map || !data.containsKey(listKey)) return [];

    final list = data[listKey] as List<dynamic>? ?? [];
    return list.map((e) => fromJson(e)).whereType<T>().toList();
  }

  static Map<String, dynamic>? extractData(dynamic responseData) {
    if (responseData == null) return null;
    if (responseData is! Map) return null;
    final inner = responseData['data'];
    if (inner is! Map<String, dynamic>) return null;
    return inner;
  }
}
