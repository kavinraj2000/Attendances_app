import 'package:dio/dio.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/model/leave_req_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:logger/logger.dart';

class LeaveFormRepository {
  LeaveFormRepository()
    : dio = Dio(
        BaseOptions(
          baseUrl: Api.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    _setupInterceptors();
  }

  final Dio dio;
  final Logger log = Logger();
  final pref = PreferencesRepository();

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            options.headers.addAll(await Api.headers());
            handler.next(options);
          } catch (e) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'Failed to set headers: $e',
              ),
            );
          }
        },
        onError: (error, handler) {
          log.e('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Creates a new leave request
  Future<LeaveRequestModel> leaverequest({
    required String leaveType,
    required String reason,
    required DateTime startdate,
    required DateTime enddate,
  }) async {
    try {
      final user = await pref.getUserData();
      final id = await pref.getEmployeeId();

      if (user == null || id == null) {
        throw Exception('Session expired. Please login again');
      }

      final payload = {
        "requestname": "add_leave_request",
        "data": {
          "employee_id": id,
          "leave_type": leaveType,
          "start_date": startdate.toIso8601String(),
          "end_date": enddate.toIso8601String(),
          "reason": reason,
        },
      };

      final response = await dio.post(
        Constants.api.leaveREQUEST,
        data: payload,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
        ),
      );

      log.i('Create leave request response: ${response.statusCode}');
      log.d('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final int? createdId = responseData is Map
            ? (responseData['data']?['id'] ?? responseData['id'])
            : null;

        final leaveRequest = LeaveRequestModel(
          id: createdId,
          endDate: enddate,
          leaveType: leaveType,
          startDate: startdate,
          reason: reason,
        );

        return leaveRequest;
      }

      if (response.statusCode == 400) {
        final errorMessage =
            response.data?['message'] ??
            response.data?['error'] ??
            'Invalid leave request data';
        throw Exception(errorMessage);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expired. Please login again');
      }

      if (response.statusCode == 409) {
        final errorMessage =
            response.data?['message'] ??
            'Leave request already exists for this period';
        throw Exception(errorMessage);
      }

      final errorMessage =
          response.data?['message'] ??
          response.data?['error'] ??
          'Failed to create leave request';
      throw Exception(errorMessage);
    } on DioException catch (e) {
      log.e('Create leave request API error', error: e);
      throw _handleDioError(e, 'Failed to create leave request');
    } catch (e) {
      log.e('Create leave request error', error: e);
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create leave request');
    }
  }

  Future<LeaveRequestModel> updateLeaveRequest({
    required int leaveRequestId,
    String? leaveType,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = await pref.getUserData();

      if (user == null) {
        throw Exception('Session expired. Please login again');
      }

      final payload = {
        "requestname": "add_leave_request",
        "data": {
          "id": leaveRequestId,
          "leave_type": leaveType,
          "start_date": startDate!.toIso8601String(),
          "end_date": endDate!.toIso8601String(),
          "reason": reason,
        },
      };

      log.d('UPDATE payload: $payload');

      final response = await dio.post(
        Constants.api.editleaveREQUEST,
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (_) => true,
        ),
      );

      log.i('Update response: ${response.statusCode}');
      log.d('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LeaveRequestModel(
          id: leaveRequestId,
          leaveType: leaveType!,
          startDate: startDate,
          endDate: endDate,
          reason: reason!,
        );
      }

      // Handle specific error status codes
      if (response.statusCode == 400) {
        final errorMessage =
            response.data?['message'] ??
            response.data?['error'] ??
            'Invalid leave request data';
        throw Exception(errorMessage);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expired. Please login again');
      }

      if (response.statusCode == 404) {
        throw Exception('Leave request not found');
      }

      if (response.statusCode == 409) {
        final errorMessage =
            response.data?['message'] ??
            'Cannot update - conflicting leave request exists';
        throw Exception(errorMessage);
      }

      throw Exception(
        response.data?['message'] ??
            response.data?['error'] ??
            'Failed to update leave request',
      );
    } on DioException catch (e) {
      log.e('Update leave request API error', error: e);
      throw _handleDioError(e, 'Failed to update leave request');
    } catch (e) {
      log.e('Update leave request error', error: e);
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to update leave request');
    }
  }

  Exception _handleDioError(DioException error, String defaultMessage) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please try again');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection. Please check your network');
    }

    if (error.type == DioExceptionType.badResponse) {
      if (error.response?.statusCode == 500) {
        return Exception('Server error. Please try again later');
      }
      if (error.response?.statusCode == 503) {
        return Exception('Service unavailable. Please try again later');
      }
    }

    if (error.response?.data != null) {
      final message =
          error.response!.data['message'] ?? error.response!.data['error'];
      if (message != null) {
        return Exception(message);
      }
    }

    return Exception(defaultMessage);
  }

  void dispose() {
    dio.close();
  }
}
