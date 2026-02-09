import 'package:dio/dio.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:intl/intl.dart';
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

  Future<AttendanceModel> checkIn({
    required double lat,
    required double lng,
    String? imageName,
  }) async {
    final user = await pref.getUserData();
    final id = await pref.getEmployeeId();

    if (user == null || id == null) {
      throw Exception('User session expired. Please Auth again');
    }

    final now = DateTime.now();

    final payload = {
      "requestname": "data_add",
      "data": {
        "tablename": "users",
        "columndata": {"email": "test1", "password_hash": "test"},
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

      log.i('Check-in response: ${response.statusCode}');
      log.d('Check-in response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final attendance = AttendanceModel(
          employeeId: id.toString(),
          attendanceDate: DateFormat('yyyy-MM-dd').format(now),
          checkinTime: now,
          checkinLatitude: lat,
          checkinLongitude: lng,
          checkinImage: imageName,
        );

        return attendance;
      }

      final errorMessage =
          response.data?['message'] ??
          response.data?['error'] ??
          'Check-in failed';
      throw Exception(errorMessage);
    } on DioException catch (e) {
      log.e('Check-in API error', error: e);
      throw _handleDioError(e, 'Check-in failed');
    } catch (e) {
      log.e('Check-in error', error: e);
      rethrow;
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
