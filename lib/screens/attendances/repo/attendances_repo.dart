import 'package:dio/dio.dart';
import 'package:hrm/core/constants/constants.dart';
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
          log.e(
            'API Error',
            error: error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );
  }

  Future<List<AttendanceModel>> getAllAttendanceData() async {
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
          "where": {
            "employee_id": user.employeeId.toString(),
          },
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
          'Attendance fetch failed | status: ${response.statusCode} | body: ${response.data}',
        );
      if (response.statusCode != 200 && response.statusCode != 201) {
        
        final errorMessage = response.data?['message'] ?? 
                            response.data?['error'] ?? 
                            'Failed to fetch attendance data';
        throw Exception(errorMessage);
      }

      final data = response.data;
      if (data == null || data['data'] == null) {
        log.w('Attendance response data is empty');
        return []; 
      }

      final List list = data['data'];
      return list.map((e) => AttendanceModel.fromJson(e)).toList();
      
    } on DioException catch (e) {
      log.e('Dio error while fetching attendance', error: e);
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server response timeout. Please try again');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      } else if (e.response?.data != null) {
        final errorMessage = e.response!.data['message'] ?? 
                            e.response!.data['error'] ?? 
                            'Network error occurred';
        throw Exception(errorMessage);
      }
      
      throw Exception('Failed to fetch attendance data');
      
    } catch (e, s) {
      log.e('Unexpected error parsing attendance', error: e, stackTrace: s);
      
      if (e is Exception) {
        rethrow;
      }
      
      throw Exception('Failed to load attendance data');
    }
  }

  void dispose() {
    dio.close();
  }
}