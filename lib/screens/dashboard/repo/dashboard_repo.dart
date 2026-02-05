import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/localdb_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/screens/login/repo/login_repo.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class DashboardRepository {
  DashboardRepository()
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
  final LoginRepo loginRepo = LoginRepo();
  final LocalDBRepository attendanceDB = LocalDBRepository();
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
      throw Exception('User session expired. Please login again');
    }

    final now = DateTime.now();

    final payload = {
      "requestname": "Employee Check In",
      "data": {
        "employee_id": id,
        "checkin_time": now,
        "checkin_latitude": lat,
        "checkin_longitude": lng,
        "checkin_image": imageName ?? '',
        "created_by": user.username,
      },
    };

    try {
      final response = await dio.post(
        Constants.api.checkIn,
        data: payload,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
        ),
      );

      log.i('Check-in response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final attendance = AttendanceModel(
          employeeId: id.toString(),
          attendanceDate: DateFormat('yyyy-MM-dd').format(now),
          checkinTime: now,
          checkinLatitude: lat,
          checkinLongitude: lng,
          checkinImage: imageName,
        );
        await _saveToLocalDB(attendance);

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

  Future<void> checkOut({
    required double lat,
    required double lng,
    File? image,
  }) async {
    final user = await pref.getUserData();
    if (user == null || user.employeeId == null) {
      throw Exception('User session expired. Please login again');
    }

    final now = DateTime.now();

    try {
      final formData = FormData.fromMap({
        "requestname": "Employee Check In",
        "employee_id": user.employeeId,
        "checkout_time": DateFormat('HH:mm:ss').format(now),
        "checkout_latitude": lat,
        "checkout_longitude": lng,
        "modified_by": user.username,
      });

      if (image != null) {
        formData.files.add(
          MapEntry(
            "checkout_image",
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      final response = await dio.post(
        Constants.api.checkOut,
        data: formData,
        options: Options(
          validateStatus: (_) => true,
          contentType: 'multipart/form-data',
        ),
      );

      log.i('Check-out response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMessage =
            response.data?['message'] ??
            response.data?['error'] ??
            'Check-out failed';
        throw Exception(errorMessage);
      }

      await _updateLocalDBCheckout(user.employeeId.toString(), now);
    } on DioException catch (e) {
      log.e('Check-out API error', error: e);
      throw _handleDioError(e, 'Check-out failed');
    } catch (e) {
      log.e('Check-out error', error: e);
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

  Future<AttendanceModel?> getAttendanceDataByDate({
    required DateTime date,
  }) async {
    final user = await pref.getUserData();
    if (user == null || user.employeeId == null) {
      log.w('User not logged in');
      return null;
    }

    final payload = {
      "requestname": "data_read",
      "data": {
        "tablename": "attendance_details",
        "columns": [],
        "where": {
          "employee_id": user.employeeId.toString(),
          "attendance_date": DateFormat('yyyy-MM-dd').format(date),
        },
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
        log.w('Failed to fetch attendance for date: ${response.statusCode}');
        return null;
      }

      final list = response.data['data'] as List<dynamic>?;
      if (list == null || list.isEmpty) return null;

      return AttendanceModel.fromJson(list.first);
    } on DioException catch (e) {
      log.e('Failed to fetch attendance by date', error: e);
      return null;
    } catch (e) {
      log.e('Error parsing attendance data', error: e);
      return null;
    }
  }

  Future<void> _saveToLocalDB(AttendanceModel attendance) async {
    try {
      await attendanceDB.save(attendance);
      log.i('Saved attendance to local database');
    } catch (e) {
      log.e('Failed to save to local database', error: e);
    }
  }

  Future<void> _updateLocalDBCheckout(
    String employeeId,
    DateTime checkoutTime,
  ) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final attendance = await attendanceDB.getByDate(employeeId, today);

      if (attendance != null) {
        final updated = attendance.copyWith(checkoutTime: checkoutTime);
        await attendanceDB.update(updated);
        log.i('Updated checkout in local database');
      }
    } catch (e) {
      log.e('Failed to update local database', error: e);
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
