import 'dart:convert';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/login_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/localdb_repo.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class LoginRepo {
  final log = Logger();
  final LocalDBrepostiory _dbHelper = LocalDBrepostiory();

  Future<LoginModel> requestLogin({
    required String email,
    required String password,
  }) async {
    try {
      final baseapi = Api.baseUrl;
      log.d('requestLogin:baseapi:$baseapi');
      final url = baseapi + Constants.api.verifyemail;
      log.d('requestLogin:url:$url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "requestname": "verify_email",
          "data": {"email": email, "password": password},
        }),
      );

      log.d('requestLogin:response:${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginModel = LoginModel.fromJson(data);

        if (loginModel.success == true && loginModel.token != null) {
          if (loginModel.data != null) {
            try {
              await _dbHelper.saveUser(loginModel.data!);
              log.d('User data saved to SQLite database');
            } catch (e) {
              log.e('Error saving user to SQLite: $e');
            }
          }

          if (loginModel.token != null) {
            await _dbHelper.saveToken(loginModel.token!);
          }

          if (loginModel.userId != null) {
            await _dbHelper.saveUserId(loginModel.userId.toString());
          }
              if (loginModel.responder != null) {
            await _dbHelper.saveUserId(loginModel.userId.toString());
          }

          await _dbHelper.setLoggedIn(true);
        }

        return loginModel;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (response.statusCode == 404) {
        throw Exception('Login endpoint not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later');
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await _dbHelper.isLoggedIn();
    } catch (e) {
      log.e('Error checking login status: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _dbHelper.getAccessToken();
      return (token != null && token.isNotEmpty) ? token : null;
    } catch (e) {
      log.e('Error getting token: $e');
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      final userId = await _dbHelper.getUserId();
      return userId?.toString();
    } catch (e) {
      log.e('Error getting user ID: $e');
      return null;
    }
  }

  Future<LoginData?> getUserData() async {
    try {
      return await _dbHelper.getUser();
    } catch (e) {
      log.e('Error getting user data: $e');
      return null;
    }
  }

  Future<int?> getEmployeeId() async {
    try {
      return await _dbHelper.getEmployeeId();
    } catch (e) {
      log.e('Error getting employee ID: $e');
      return null;
    }
  }

  /// Get company ID from SQLite
  Future<int?> getCompanyId() async {
    try {
      return await _dbHelper.getCompanyId();
    } catch (e) {
      log.e('Error getting company ID: $e');
      return null;
    }
  }

  Future<void> updateToken(String newToken) async {
    try {
      await _dbHelper.updateAccessToken(newToken);
      log.d('Token updated in SQLite');
    } catch (e) {
      log.e('Error updating token: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dbHelper.logout();
      log.d('User logged out and data cleared from SQLite');
    } catch (e) {
      log.e('Error during logout: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  Future<void> clearAllStorage() async {
    try {
      await _dbHelper.clearAllData();
      log.d('All storage cleared from SQLite');
    } catch (e) {
      log.e('Error clearing storage: $e');
    }
  }

  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final dbUser = await _dbHelper.getUserInfo();
      final dbLoggedIn = await _dbHelper.isLoggedIn();
      final token = await _dbHelper.getAccessToken();
      final userId = await _dbHelper.getUserId();

      return {
        'sqlite': {
          'logged_in': dbLoggedIn,
          'token': token?.substring(0, 20) ?? 'null',
          'user_id': userId,
          'user_data': dbUser,
        },
      };
    } catch (e) {
      log.e('Error getting debug info: $e');
      return {'error': e.toString()};
    }
  }
}
