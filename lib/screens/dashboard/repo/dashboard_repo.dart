import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/util/error_handler.dart';
import 'package:hrm/core/util/response_handler.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
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
  final pref = PreferencesRepository();

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            options.headers.addAll(await Api.headers());
            log.d('Request: ${options.method} ${options.path}');
            handler.next(options);
          } catch (e) {
            log.e('Failed to set headers: $e');
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'Failed to set headers: $e',
              ),
            );
          }
        },
        onResponse: (response, handler) {
          log.d('Response [${response.statusCode}]: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          log.e('API Error [${error.response?.statusCode}]: ${error.message}');
          log.e('API Error body: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  Future<String> uploadImage({required File file, required int value}) async {
    try {
      final user = await pref.getUserData();
      if (user == null || user.employeeId == null) {
        throw Exception('User session expired. Please login again');
      }
      if (!file.existsSync()) throw Exception("Image file not found");

      final fileName = file.path.split('/').last;
      log.i("Uploading file: $fileName");

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'checking': value,
      });

      final response = await dio.post(
        Constants.api.uploadImage,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      log.d("Upload response [${response.statusCode}]: ${response.data}");

      return ResponseHandler.handle<String>(
        statusCode: response.statusCode,
        data: response.data,
        defaultError: 'Image upload failed',
        onSuccess: (data) {
          if (data is Map && data['filename'] != null) {
            return data['filename'];
          }
          throw Exception("Invalid server response format");
        },
      );
    } on DioException catch (e) {
      log.e("Upload DioException: ${e.response?.data}");
      throw DioErrorHandler.handle(e, "Image upload failed");
    } catch (e) {
      log.e("Upload error: $e");
      rethrow;
    }
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
        "checkin_time": now.toIso8601String(),
        "checkin_latitude": lat,
        "checkin_longitude": lng,
        "checkin_image": imageName ?? '',
        "created_by": user.username,
      },
    };

    try {
      log.d('Check-in payload: ${jsonEncode(payload)}');

      final response = await dio.post(
        Constants.api.checkIn,
        data: payload,
        options: Options(
          validateStatus: (status) => status != null && status <= 500,
          contentType: Headers.acceptHeader,
        ),
      );

      log.i('Check-in response [${response.statusCode}]: ${response.data}');

      return ResponseHandler.handle<AttendanceModel>(
        statusCode: response.statusCode,
        data: response.data,
        defaultError: 'Check-in failed',
        onSuccess: (_) {
          log.i('Check-in successful');
           pref.saveCheckInState(now);
          return AttendanceModel(
            employeeId: id.toString(),
            attendanceDate: DateFormat('yyyy-MM-dd').format(now),
            checkinTime: now,
            checkinLatitude: lat,
            checkinLongitude: lng,
            checkinImage: imageName,
          );
        },
      );
    } on DioException catch (e) {
      log.e('Check-in network error: ${e.type} | body: ${e.response?.data}');
      throw DioErrorHandler.handle(e, 'Check-in failed');
    } catch (e) {
      log.e('Check-in error: $e');
      rethrow;
    }
  }

  Future<void> checkOut({
    required double lat,
    required double lng,
    String? image,
  }) async {
    final user = await pref.getUserData();
    if (user == null || user.employeeId == null) {
      throw Exception('User session expired. Please login again');
    }

    final now = DateTime.now();
    final payload = {
      "requestname": "Employee Check In",
      "data": {
        "employee_id": user.employeeId,
        "checkout_time": now.toIso8601String(),
        "checkout_latitude": lat,
        "checkout_longitude": lng,
        "checkout_image": image ?? '',
        "modified_by": user.username,
      },
    };

    try {
      log.d('Check-out payload: ${jsonEncode(payload)}');

      final response = await dio.post(
        Constants.api.checkOut,
        data: payload,
        options: Options(
          validateStatus: (status) => status != null && status <= 500,
          contentType: Headers.jsonContentType,
        ),
      );

      log.i('Check-out response [${response.statusCode}]: ${response.data}');

      ResponseHandler.handle<void>(
        statusCode: response.statusCode,
        data: response.data,
        defaultError: 'Check-out failed',
        onSuccess: (_) async {
          log.i('Check-out successful');
          await pref.saveCheckOutState(now);
        },
      );
    } on DioException catch (e) {
      log.e('Check-out network error: ${e.type} | body: ${e.response?.data}');
      throw DioErrorHandler.handle(e, 'Check-out failed');
    } catch (e) {
      log.e('Check-out error: $e');
      rethrow;
    }
  }

  Future<List<AttendanceModel>> getAllAttendanceData() async {
    final user = await pref.getUserData();
    if (user == null || user.employeeId == null) {
      log.w('User not logged in - returning empty attendance list');
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
      log.d('Fetching attendance data for employee: ${user.employeeId}');

      final response = await dio.post(
        Constants.api.getdata,
        data: payload,
        options: Options(
          validateStatus: (status) => status != null && status <= 500,
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expired. Please login again');
      }

      final attendanceList = ResponseHandler.handleList<AttendanceModel>(
        statusCode: response.statusCode,
        data: response.data,
        fromJson: (e) => AttendanceModel.fromJson(e),
      );

      attendanceList.sort((a, b) {
        final aDate = a.checkinTime ?? DateTime(1970);
        final bDate = b.checkinTime ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      log.d('Fetched ${attendanceList.length} attendance records');
      return attendanceList;
    } on DioException catch (e) {
      log.e('Network error fetching attendance data: ${e.type}');
      return [];
    } catch (e) {
      log.e('Error parsing attendance data: $e');
      return [];
    }
  }

  Future<AttendanceModel?> getActiveAttendanceSession() async {
    final user = await pref.getUserData();
    if (user == null || user.employeeId == null) return null;

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
          validateStatus: (status) => status != null && status <= 500,
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) return null;

      final list = response.data['data'] as List<dynamic>? ?? [];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (final e in list) {
        try {
          final model = AttendanceModel.fromJson(e);
          if (model.checkinTime == null) continue;
          if (model.checkoutTime != null) continue;
          if (model.attendanceStatus == 'PENDING') continue;

          final checkinDate = DateTime(
            model.checkinTime!.year,
            model.checkinTime!.month,
            model.checkinTime!.day,
          );

          if (checkinDate.isAtSameMomentAs(today)) return model;
          if (now.difference(model.checkinTime!).inHours <= 24) return model;
        } catch (parseError) {
          log.e('Error parsing attendance record: $parseError');
        }
      }
      return null;
    } catch (e) {
      log.e('Error fetching active attendance session: $e');
      return null;
    }
  }

  Future<AttendanceModel?> getActiveAttendance() async {
    final list = await getAllAttendanceData();
    try {
      return list.firstWhere((a) => a.isActiveCheckIn);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    dio.close();
  }
}