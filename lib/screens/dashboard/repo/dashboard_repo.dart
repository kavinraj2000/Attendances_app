import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/helper/camara_helper.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/localdb_repo.dart';
import 'package:hrm/screens/login/repo/login_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

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
  final ImagePicker picker = ImagePicker();
  final CameraLockService _cameraLock = CameraLockService();

  // ───────────────── SETUP ─────────────────

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

  // ───────────────── IMAGE CAPTURE ─────────────────

  /// Captures and compresses an image from the front camera
  Future<File?> captureImage() async {
    if (!_cameraLock.tryLock()) {
      log.w('Camera already in use');
      throw Exception('Camera is currently in use');
    }

    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );

      if (file == null) {
        log.i('User cancelled image capture');
        return null;
      }

      return await _compressImage(file);
    } catch (e) {
      log.e('Failed to capture image', error: e);
      rethrow;
    } finally {
      // Small delay to ensure camera resources are released
      await Future.delayed(const Duration(milliseconds: 500));
      _cameraLock.release();
    }
  }

  /// Compresses image to reduce file size
  Future<File?> _compressImage(XFile file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${tempDir.path}/attendance_$timestamp.jpg';

      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 65,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) {
        log.w('Image compression failed');
        return File(file.path);
      }

      return File(compressed.path);
    } catch (e) {
      log.e('Failed to compress image', error: e);
      // Return original file if compression fails
      return File(file.path);
    }
  }

  // ───────────────── CHECK IN ─────────────────

  /// Performs check-in operation
  Future<AttendanceModel> checkIn({
    required double lat,
    required double lng,
    String? imageName,
  }) async {
    // Validate user session
    final user = await loginRepo.getUserData();
    final id = await loginRepo.getEmployeeId();

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

        // Save to local database
        await _saveToLocalDB(attendance);
        
        return attendance;
      }

      // Handle error response
      final errorMessage = response.data?['message'] ?? 
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

  // ───────────────── CHECK OUT ─────────────────

  /// Performs check-out operation
  Future<void> checkOut({
    required double lat,
    required double lng,
    File? image,
  }) async {
    // Validate user session
    final user = await loginRepo.getUserData();
    if (user == null || user.employeeId == null) {
      throw Exception('User session expired. Please login again');
    }

    final now = DateTime.now();

    try {
      // Prepare form data
      final formData = FormData.fromMap({
        "requestname": "Employee Check Out",
        "employee_id": user.employeeId,
        "checkout_time": DateFormat('HH:mm:ss').format(now),
        "checkout_latitude": lat,
        "checkout_longitude": lng,
        "modified_by": user.username,
      });

      // Add image if available
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
        final errorMessage = response.data?['message'] ?? 
                            response.data?['error'] ?? 
                            'Check-out failed';
        throw Exception(errorMessage);
      }

      // Update local database
      await _updateLocalDBCheckout(user.employeeId.toString(), now);
    } on DioException catch (e) {
      log.e('Check-out API error', error: e);
      throw _handleDioError(e, 'Check-out failed');
    } catch (e) {
      log.e('Check-out error', error: e);
      rethrow;
    }
  }

  // ───────────────── ATTENDANCE DATA ─────────────────

  /// Retrieves all attendance records for the current user
  Future<List<AttendanceModel>> getAllAttendanceData() async {
    final user = await loginRepo.getUserData();
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

  /// Retrieves attendance record for a specific date
  Future<AttendanceModel?> getAttendanceDataByDate({
    required DateTime date,
  }) async {
    final user = await loginRepo.getUserData();
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

  // ───────────────── LOCAL DATABASE ─────────────────

  /// Saves attendance record to local database
  Future<void> _saveToLocalDB(AttendanceModel attendance) async {
    try {
      await attendanceDB.save(attendance);
      log.i('Saved attendance to local database');
    } catch (e) {
      log.e('Failed to save to local database', error: e);
      // Don't throw - local save failure shouldn't fail the check-in
    }
  }

  /// Updates checkout time in local database
  Future<void> _updateLocalDBCheckout(String employeeId, DateTime checkoutTime) async {
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
      // Don't throw - local update failure shouldn't fail the check-out
    }
  }

  // ───────────────── ERROR HANDLING ─────────────────

  /// Converts Dio errors to user-friendly exceptions
  Exception _handleDioError(DioException error, String defaultMessage) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Request timed out. Please try again');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('Network error. Please check your connection');
    }

    if (error.response?.data != null) {
      final message = error.response!.data['message'] ?? 
                     error.response!.data['error'];
      if (message != null) {
        return Exception(message);
      }
    }

    return Exception(defaultMessage);
  }

  // ───────────────── CLEANUP ─────────────────

  /// Disposes resources
  void dispose() {
    dio.close();
  }
}