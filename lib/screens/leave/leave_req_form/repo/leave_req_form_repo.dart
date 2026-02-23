import 'package:dio/dio.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/util/error_handler.dart';
import 'package:hrm/core/util/response_handler.dart';
import 'package:hrm/core/model/leave_model.dart';
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
    required int? leaveTypeID,
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
          "leave_type": leaveType,
          "leave_type_id": leaveTypeID,
          "start_date": startdate.toIso8601String(),
          "end_date": enddate.toIso8601String(),
          "reason": reason,
        },
      };

      final response = await dio.post(
        Constants.api.leaveREQUEST,
        data: payload,
        options: Options(validateStatus: (_) => true),
      );

      log.i('Create leave response: ${response.statusCode} | ${response.data}');

      return ResponseHandler.handle<LeaveRequestModel>(
        statusCode: response.statusCode,
        data: response.data,
        defaultError: 'Failed to create leave request',
        onSuccess: (data) {
          final int? createdId = data is Map
              ? (data['data']?['id'] ?? data['id'])
              : null;
          return LeaveRequestModel(
            id: createdId,
            leaveType: leaveType,
            startDate: startdate,
            endDate: enddate,
            reason: reason,
          );
        },
      );
    } on DioException catch (e) {
      log.e('Create leave request error', error: e);
      throw DioErrorHandler.handle(e, 'Failed to create leave request');
    }
  }

  Future<LeaveRequestModel> updateLeaveRequest({
    required int leaveRequestId,
    required String leaveType,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final user = await pref.getUserData();
      if (user == null) throw Exception('Session expired. Please login again');

      final payload = {
        "requestname": "add_leave_request",
        "data": {
          "id": leaveRequestId,
          "leave_type": leaveType,
          "start_date": startDate.toIso8601String(),
          "end_date": endDate.toIso8601String(),
          "reason": reason,
        },
      };

      log.d('UPDATE payload: $payload');

      final response = await dio.post(
        Constants.api.editleaveREQUEST,
        data: payload,
        options: Options(validateStatus: (_) => true),
      );

      log.i('Update response: ${response.statusCode} | ${response.data}');

      return ResponseHandler.handle<LeaveRequestModel>(
        statusCode: response.statusCode,
        data: response.data,
        defaultError: 'Failed to update leave request',
        onSuccess: (_) => LeaveRequestModel(
          id: leaveRequestId,
          leaveType: leaveType,
          startDate: startDate,
          endDate: endDate,
          reason: reason,
        ),
      );
    } on DioException catch (e) {
      log.e('Update leave request error', error: e);
      throw DioErrorHandler.handle(e, 'Failed to update leave request');
    }
  }

  Future<List<LeaveModel>> getLeaveReason() async {
    try {
      final payload = {
        "requestname": "data_list",
        "data": {"tablename": "leave_types"},
      };

      final response = await dio.post(
        Constants.api.listDATA,
        data: payload,
        options: Options(validateStatus: (_) => true),
      );

      log.d('getLeaveReason: ${response.realUri} | ${response.data}');

      return ResponseHandler.handleList<LeaveModel>(
        statusCode: response.statusCode,
        data: response.data,
        fromJson: (e) => LeaveModel.fromJson(e),
      );
    } on DioException catch (e) {
      log.e('Get leave reason error', error: e);
      throw DioErrorHandler.handle(e, 'Failed to load leave reasons');
    }
  }

  void dispose() {
    dio.close();
  }
}