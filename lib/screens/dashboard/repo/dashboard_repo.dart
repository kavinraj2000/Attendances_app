import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/model/check_in_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/screens/login/repo/login_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class DashboardRepository {
  final Logger log = Logger();
  final Dio dio;
  final ImagePicker _picker = ImagePicker();
  final LoginRepo _loginRepo = LoginRepo();

  DashboardRepository()
      : dio = Dio(
          BaseOptions(
            baseUrl: Api.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await PreferencesRepository().getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
      ),
    );
  }

  /// Capture image using camera
  Future<File?> captureImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      log.e('captureImage error: $e');
      return null;
    }
  }

  /// Add Check-in
  Future<CheckInModel> addCheckin({
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    try {
      final userData = await _loginRepo.getUserData();
      final employeeId = await _loginRepo.getEmployeeId();
      if (userData == null || employeeId == null) {
        throw Exception('User data or employee ID not found');
      }

      final payload = {
        "requestname": "Employee Check In",
        "data": {
          "employee_id": employeeId,
          "checkin_time": DateTime.now().toIso8601String(),
          "checkin_latitude": latitude,
          "checkin_longitude": longitude,
          "checkin_image": imageFile?.path.split('/').last,
          "created_by": userData.username,
        },
      };

      log.i('CHECK-IN REQUEST => $payload');

      final response = await dio.post(
        Constants.api.checkIn,
        data: payload,
        options: Options(validateStatus: (_) => true),
      );

      log.i('STATUS => ${response.statusCode}');
      log.i('BODY => ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data);
      }

      return CheckInModel(
        employeeId: employeeId,
        checkinTime: DateTime.now(),
        checkinLatitude: latitude,
        checkinLongitude: longitude,
        checkinImage: imageFile?.path.split('/').last,
        createdBy: userData.username,
      );
    } catch (e) {
      log.e('Check-in failed: $e', );
      rethrow;
    }
  }

  /// Add Check-out
  Future<CheckInModel> addCheckout({
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    try {
      final userData = await _loginRepo.getUserData();
      final employeeId = await _loginRepo.getEmployeeId();
      if (userData == null || employeeId == null) {
        throw Exception('User data or employee ID not found');
      }

      final payload = {
        "requestname": "Employee Check Out",
        "data": {
          "employee_id": employeeId,
          "checkout_time": DateTime.now().toIso8601String(),
          "checkout_latitude": latitude,
          "checkout_longitude": longitude,
          "checkout_image": imageFile?.path.split('/').last,
          "modified_by": userData.username,
        },
      };

      log.i('CHECK-OUT REQUEST => $payload');

      final response = await dio.post(
        Constants.api.checkOut,
        data: payload,
        options: Options(validateStatus: (_) => true),
      );

      log.i('STATUS => ${response.statusCode}');
      log.i('BODY => ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data);
      }

      return CheckInModel(
        employeeId: employeeId,
        checkoutTime: DateTime.now(),
        checkoutLatitude: latitude,
        checkoutLongitude: longitude,
        checkoutImage: imageFile?.path.split('/').last,
        modifiedBy: userData.username,
      );
    } catch (e) {
      log.e('Check-out failed: $e', );
      rethrow;
    }
  }

  /// Fetch attendance data
  Future<AttendanceModel?> getAttendanceData() async {
    try {
      final userData = await _loginRepo.getUserData();
      if (userData == null) return null;

      final payload = {
        "requestname": "data_read",
        "data": {
          "tablename": "attendance_details",
          "columns": [],
          "where": {"employee_id": userData.employeeId.toString()},
        },
      };

      final response = await dio.post(
        Constants.api.getdata,
        data: payload,
        options: Options(validateStatus: (_) => true),
      );

      log.i('getAttendanceData::STATUS => ${response.statusCode}');
      log.i('getAttendanceData::BODY => ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data);
      }

      final dataList = response.data['data'] as List<dynamic>?;
      if (dataList == null || dataList.isEmpty) return null;

      final json = dataList.first as Map<String, dynamic>;
      return AttendanceModel.fromJson(json);
    } catch (e, s) {
      log.e('getAttendanceData failed: $e', );
      throw Exception('Failed to fetch attendance data: $e');
    }
  }
}
