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

  Future<LeaveRequestModel> leaverequest({
    required String leaveType,
    required String reason, 
    required DateTime startdate,
    required DateTime enddate,
    String? imageName,
  }) async {
    final user = await pref.getUserData();
    final id = await pref.getEmployeeId();

    if (user == null || id == null) {
      throw Exception('User session expired. Please Auth again');
    }

    final payload = {
      "requestname": "add_leave_request",
      "data": {
        "leave_type": leaveType,
        "start_date": startdate.toIso8601String(),
        "end_date": enddate.toIso8601String(),
        "reason": reason,
      },
    };

    try {
      final response = await dio.post(
        Constants.api.leaveREQUEST,
        data: payload,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
        ),
      );

      log.i('request response: ${response.statusCode}');
      log.d('request response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final attendance = LeaveRequestModel(
          endDate: enddate,
          leaveType: leaveType,
          startDate: startdate,
          reason: reason,
        );

        return attendance;
      }

      final errorMessage =
          response.data?['message'] ??
          response.data?['error'] ??
          'request failed';
      throw Exception(errorMessage);
    } on DioException catch (e) {
      log.e('request API error', error: e);
      throw _handleDioError(e, 'request failed');
    } catch (e) {
      log.e('request error', error: e);
      rethrow;
    }
  }

  Future<List<AttendanceModel>> getAllAttendanceData() async {
    final user = await pref.getUserData();
    if (user == null || user.employeeId == null) {
      log.w('User not logged in');
      return [];
    }

    final payload = {
      "requestname": "data_read",
      "data": {
        "tablename": "attendance_details",
        "columns": [],
        "where": {"employee_id": user.employeeId.toString()},
      },
    };
 
    try {
      final response = await dio.post(
        Constants.api.getdata,
        data: payload,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
        ),
      );
      

      if (response.statusCode != 200 && response.statusCode != 201) {
        log.w('Failed to fetch attendance data: ${response.statusCode}');
        return [];
      }

      final list = response.data['data'] as List<dynamic>? ?? [];
      return list.map((e) => AttendanceModel.fromJson(e)).toList();
    } on DioException catch (e) {
      log.e('Failed to fetch attendance data', error: e);
      return [];
    } catch (e) {
      log.e('Error parsing attendance data', error: e);
      return [];
    }
  }


  Exception _handleDioError(DioException error, String defaultMessage) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Request timed out. Please try again');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('Network error. Please check your connection');
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
}
