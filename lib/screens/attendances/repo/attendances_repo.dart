import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/enum/attendance_status.dart';
import 'package:hrm/core/util/error_handler.dart';
import 'package:hrm/core/util/response_handler.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/localdb_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:logger/logger.dart';

class AttendancesRepo {
  final Logger log = Logger();
  final LocalDBRepository localDB;
  final PreferencesRepository pref;
  final Dio dio;

  AttendancesRepo(this.localDB, this.pref)
      : dio = Dio(
          BaseOptions(
            baseUrl: Api.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    _setupInterceptors();
  }

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
                error: 'Failed to attach headers: $e',
              ),
            );
          }
        },
        onError: (error, handler) {
          log.e('API Error', error: error, stackTrace: error.stackTrace);
          handler.next(error);
        },
      ),
    );
  }

  /// Returns attendance list — from API (online) or local DB (offline).
  Future<List<AttendanceModel>> getAllAttendanceData() async {
    final isOnline = await _hasConnection();

    if (!isOnline) {
      log.i('Offline — loading attendance from local DB');
      return _getLocalAttendance();
    }

    try {
      final user = await pref.getUserData();
      if (user == null || user.employeeId == null) {
        log.w('User not logged in');
        throw Exception('Session expired. Please login again');
      }

      final payload = {
        "requestname": "data_read",
        "data": {
          "tablename": "attendance_details",
          "columns": [],
          "where": {"employee_id": user.employeeId.toString()},
        },
      };

      final response = await dio.post(
        Constants.api.getdata,
        data: payload,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
        ),
      );

      log.d(
        'Attendance response | status: ${response.statusCode} | body: ${response.data}',
      );

      final records = ResponseHandler.handleList<AttendanceModel>(
        statusCode: response.statusCode,
        data: response.data,
        fromJson: (e) => AttendanceModel.fromJson(e),
      );

      await _syncToLocalDB(records);

      return records;
    } on DioException catch (e) {
      log.e('Dio error — falling back to local DB', error: e);
      final cached = await _getLocalAttendance();
      if (cached.isNotEmpty) return cached;
      throw DioErrorHandler.handle(e, 'Failed to fetch attendance data');
    } catch (e, s) {
      log.e('Unexpected error', error: e, stackTrace: s);
      if (e is Exception) rethrow;
      throw Exception('Failed to load attendance data');
    }
  }

  Future<void> _syncToLocalDB(List<AttendanceModel> records) async {
    try {
      await localDB.clearAll(); 
      for (final record in records) {
        await localDB.addData(record.copyWith(isSynced: true));
      }
      log.i('Synced ${records.length} attendance records to local DB');
    } catch (e) {
      log.w('Failed to sync to local DB', error: e);
    }
  }

  Future<List<AttendanceModel>> _getLocalAttendance() async {
    try {
      return await localDB.getAllData();
    } catch (e) {
      log.e('Failed to read local DB', error: e);
      return [];
    }
  }

  Future<bool> _hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    dio.close();
  }
}