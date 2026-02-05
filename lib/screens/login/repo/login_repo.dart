import 'dart:convert';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/login_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRepo {
  final log = Logger();

  static const String _keyAccessToken = 'access_token';
  static const String _keyUserId = 'user_id';
  static const String _keyEmployeeId = 'employee_id';
  static const String _keyCompanyId = 'company_id';
  static const String _keyUsername = 'username';
  static const String _keyUserRole = 'user_role';
  static const String _keyEmailId = 'email_id';
  static const String _keyTokenType = 'token_type';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserData = 'user_data';

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
              await _saveUserData(loginModel.data!);
              log.d('User data saved to SharedPreferences');
            } catch (e) {
              log.e('Error saving user to SharedPreferences: $e');
            }
          }
          if (loginModel.token != null) {
            await _saveToken(loginModel.token!);
            log.d('Token saved to SharedPreferences');
          }

          if (loginModel.userId != null) {
            await _saveUserId(loginModel.userId!);
            log.d('User ID saved to SharedPreferences');
          }
          await _setLoggedIn(true);
          log.d('Login status set to true');
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

Future<void> _saveUserData(LoginData userData) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(_keyUserData, jsonEncode(userData.toJson()));
  await prefs.setInt(_keyUserId, userData.userId);
  await prefs.setString(_keyUsername, userData.username);

  if (userData.employeeId != null) {
    await prefs.setInt(_keyEmployeeId, userData.employeeId!);
  }

  await prefs.setInt(_keyCompanyId, userData.companyId);
  await prefs.setString(_keyUserRole, userData.userRole.join(','));
  await prefs.setString(_keyTokenType, userData.tokenType);

  if (userData.emailId != null && userData.emailId!.isNotEmpty) {
    await prefs.setString(_keyEmailId, userData.emailId!);
  }
}


  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, token);
  }
  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  Future<void> _setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      log.e('Error checking login status: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyAccessToken);
      return (token != null && token.isNotEmpty) ? token : null;
    } catch (e) {
      log.e('Error getting token: $e');
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_keyUserId);
      return userId?.toString();
    } catch (e) {
      log.e('Error getting user ID: $e');
      return null;
    }
  }

  Future<LoginData?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_keyUserData);

      if (userDataString != null && userDataString.isNotEmpty) {
        final Map<String, dynamic> userDataMap = jsonDecode(userDataString);
        return LoginData.fromJson(userDataMap);
      }
      return null;
    } catch (e) {
      log.e('Error getting user data: $e');
      return null;
    }
  }

  Future<int?> getEmployeeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyEmployeeId);
    } catch (e) {
      log.e('Error getting employee ID: $e');
      return null;
    }
  }

  Future<int?> getCompanyId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyCompanyId);
    } catch (e) {
      log.e('Error getting company ID: $e');
      return null;
    }
  }

  Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUsername);
    } catch (e) {
      log.e('Error getting username: $e');
      return null;
    }
  }

  Future<List<String>?> getUserRoles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rolesString = prefs.getString(_keyUserRole);
      if (rolesString != null && rolesString.isNotEmpty) {
        return rolesString.split(',');
      }
      return null;
    } catch (e) {
      log.e('Error getting user roles: $e');
      return null;
    }
  }

  Future<String?> getEmailId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyEmailId);
    } catch (e) {
      log.e('Error getting email ID: $e');
      return null;
    }
  }

  Future<void> updateToken(String newToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, newToken);
      log.d('Token updated in SharedPreferences');
    } catch (e) {
      log.e('Error updating token: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await clearAllStorage();
      log.d('User logged out and data cleared from SharedPreferences');
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      log.d('All storage cleared from SharedPreferences');
    } catch (e) {
      log.e('Error clearing storage: $e');
    }
  }

  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      final token = prefs.getString(_keyAccessToken);
      final userId = prefs.getInt(_keyUserId);
      final username = prefs.getString(_keyUsername);
      final employeeId = prefs.getInt(_keyEmployeeId);
      final companyId = prefs.getInt(_keyCompanyId);

      return {
        'shared_preferences': {
          'logged_in': isLoggedIn,
          'token': token?.substring(0, 20) ?? 'null',
          'user_id': userId,
          'username': username,
          'employee_id': employeeId,
          'company_id': companyId,
        },
      };
    } catch (e) {
      log.e('Error getting debug info: $e');
      return {'error': e.toString()};
    }
  }
}
