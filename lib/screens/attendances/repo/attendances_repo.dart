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
        "where": {
          "employee_id": user.employeeId.toString(),
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
        log.d(
          'Attendance fetch failed | status: ${response.statusCode} | body: ${response.data}',
        );
        return []; 
      }

      final data = response.data;
      if (data == null || data['data'] == null) {
        log.w('Attendance response data is empty');
        return []; 
      }

      final List list = data['data'];
      return list
          .map((e) => AttendanceModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      log.e('Dio error while fetching attendance', error: e);
      return [];
    } catch (e, s) {
      log.e('Unexpected error parsing attendance', error: e, stackTrace: s);
      return [];
    }
  }
}