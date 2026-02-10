import 'dart:convert';

import 'package:hrm/core/model/login_model.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/core/config/app_config.dart';

class PreferencesRepository {
  static const _checkInStartKey = 'check_in_start_time';
  final log = Logger();
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear data: ${e.toString()}');
    }
  }

  Future<void> saveCheckInStartTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkInStartKey, time.toIso8601String());
  }

  Future<DateTime?> getCheckInStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_checkInStartKey);
    return value != null ? DateTime.parse(value) : null;
  }

  Future<void> clearCheckInStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkInStartKey);
  }

  Future<void> saveUserData(LoginData userData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(AppConfig.UserData, jsonEncode(userData.toJson()));
    await prefs.setInt(AppConfig.UserId, userData.userId);
    await prefs.setString(AppConfig.Username, userData.username);

    if (userData.employeeId != null) {
      await prefs.setInt(AppConfig.EmployeeId, userData.employeeId!);
    }

    await prefs.setInt(AppConfig.CompanyId, userData.companyId);
    await prefs.setString(AppConfig.UserRole, userData.userRole.join(','));
    await prefs.setString(AppConfig.TokenType, userData.tokenType);

    if (userData.emailId != null && userData.emailId!.isNotEmpty) {
      await prefs.setString(AppConfig.EmailId, userData.emailId!);
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.AccessToken, token);
  }

  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConfig.UserId, userId);
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.IsLoggedIn, isLoggedIn);
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConfig.IsLoggedIn) ?? false;
    } catch (e) {
      log.e('Error checking login status: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.AccessToken);
      return (token != null && token.isNotEmpty) ? token : null;
    } catch (e) {
      log.e('Error getting token: $e');
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(AppConfig.UserId);
      return userId?.toString();
    } catch (e) {
      log.e('Error getting user ID: $e');
      return null;
    }
  }

  Future<LoginData?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConfig.UserData);

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
      return prefs.getInt(AppConfig.EmployeeId);
    } catch (e) {
      log.e('Error getting employee ID: $e');
      return null;
    }
  }

  Future<int?> getCompanyId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(AppConfig.CompanyId);
    } catch (e) {
      log.e('Error getting company ID: $e');
      return null;
    }
  }

  Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConfig.Username);
    } catch (e) {
      log.e('Error getting username: $e');
      return null;
    }
  }

  Future<List<String>?> getUserRoles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rolesString = prefs.getString(AppConfig.UserRole);
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
      return prefs.getString(AppConfig.EmailId);
    } catch (e) {
      log.e('Error getting email ID: $e');
      return null;
    }
  }

  Future<void> updateToken(String newToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.AccessToken, newToken);
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
      final isLoggedIn = prefs.getBool(AppConfig.IsLoggedIn) ?? false;
      final token = prefs.getString(AppConfig.AccessToken);
      final userId = prefs.getInt(AppConfig.UserId);
      final username = prefs.getString(AppConfig.Username);
      final employeeId = prefs.getInt(AppConfig.EmployeeId);
      final companyId = prefs.getInt(AppConfig.CompanyId);

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
