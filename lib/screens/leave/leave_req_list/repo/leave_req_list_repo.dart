import 'package:dio/dio.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/leave_list_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:logger/logger.dart';

class LeaveReqListRepo {
  LeaveReqListRepo()
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
  final PreferencesRepository pref = PreferencesRepository();

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers.addAll(await Api.headers());
          handler.next(options);
        },
        onError: (error, handler) {
          log.e('API Error', error: error);
          handler.next(error);
        },
      ),
    );
  }

  Future<List<LeaveRequestListModel>> leaverequest() async {
    final employeeId = await pref.getEmployeeId();

    if (employeeId == null) {
      throw Exception('User session expired. Please login again');
    }

    final payload = {
      "requestname": "data_read",
      "data": {
        "tablename": "employee_leave_requests",
        "columns": [],
        "where": {"employee_id": employeeId},
      },
    };

    log.d('Leave list payload: $payload');

    try {
      final response = await dio.post(
        Constants.api.getdata,
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (_) => true,
        ),
      );

      log.i('Leave list response code: ${response.statusCode}');
      log.d('Leave list response body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> list = response.data['data'] ?? [];

        return list
            .map(
              (e) => LeaveRequestListModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }

      final errorMessage =
          response.data?['message'] ??
          response.data?['error'] ??
          'Failed to fetch leave list';

      throw Exception(errorMessage);
    } on DioException catch (e) {
      log.e('Leave list API error', error: e);
      throw _handleDioError(e, 'Failed to load leave requests');
    }
  }

  Exception _handleDioError(DioException error, String defaultMessage) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Request timed out. Please try again');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection');
    }

    return Exception(defaultMessage);
  }
}
