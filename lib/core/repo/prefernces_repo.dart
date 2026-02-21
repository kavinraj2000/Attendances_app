import 'dart:convert';

import 'package:hrm/core/model/login_model.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/core/config/app_config.dart';

class PreferencesRepository {
  static const _checkInStartKey = 'check_in_start_time';
  static const _authStatusKey = 'auth_status';
  static const _emailid = 'email_id';

  static const _isCheckedInKey = 'attendance_is_checked_in';
  static const _isCheckedOutKey = 'attendance_is_checked_out';
  static const _checkInTimeKey = 'attendance_check_in_time';
  static const _checkOutTimeKey = 'attendance_check_out_time';
  static const _checkInDateKey = 'attendance_check_in_date';

  final log = Logger();

  Future<void> saveCheckInState(DateTime checkInTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _todayString();
      await prefs.setBool(_isCheckedInKey, true);
      await prefs.setBool(_isCheckedOutKey, false);
      await prefs.setString(_checkInTimeKey, checkInTime.toIso8601String());
      await prefs.remove(_checkOutTimeKey);
      await prefs.setString(_checkInDateKey, today);
      log.d('Saved check-in state: $checkInTime');
    } catch (e) {
      log.e('Error saving check-in state: $e');
    }
  }

  Future<void> saveCheckOutState(DateTime checkOutTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isCheckedInKey, false);
      await prefs.setBool(_isCheckedOutKey, true);
      await prefs.setString(_checkOutTimeKey, checkOutTime.toIso8601String());
      log.d('Saved check-out state: $checkOutTime');
    } catch (e) {
      log.e('Error saving check-out state: $e');
    }
  }

  Future<bool> getIsCheckedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _resetAttendanceIfNewDay(prefs);
      return prefs.getBool(_isCheckedInKey) ?? false;
    } catch (e) {
      log.e('Error getting check-in state: $e');
      return false;
    }
  }

  Future<bool> getIsCheckedOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _resetAttendanceIfNewDay(prefs);
      return prefs.getBool(_isCheckedOutKey) ?? false;
    } catch (e) {
      log.e('Error getting check-out state: $e');
      return false;
    }
  }

  Future<DateTime?> getCheckInTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _resetAttendanceIfNewDay(prefs);
      final raw = prefs.getString(_checkInTimeKey);
      return raw != null ? DateTime.tryParse(raw) : null;
    } catch (e) {
      log.e('Error getting check-in time: $e');
      return null;
    }
  }

  Future<DateTime?> getCheckOutTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _resetAttendanceIfNewDay(prefs);
      final raw = prefs.getString(_checkOutTimeKey);
      return raw != null ? DateTime.tryParse(raw) : null;
    } catch (e) {
      log.e('Error getting check-out time: $e');
      return null;
    }
  }

  Future<void> clearAttendanceState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isCheckedInKey);
      await prefs.remove(_isCheckedOutKey);
      await prefs.remove(_checkInTimeKey);
      await prefs.remove(_checkOutTimeKey);
      await prefs.remove(_checkInDateKey);
      log.d('Cleared attendance state');
    } catch (e) {
      log.e('Error clearing attendance state: $e');
    }
  }

  Future<void> _resetAttendanceIfNewDay(SharedPreferences prefs) async {
    final savedDate = prefs.getString(_checkInDateKey);
    if (savedDate != null && savedDate != _todayString()) {
      await clearAttendanceState();
      log.d('New day detected — attendance state reset');
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

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
        return LoginData.fromJson(jsonDecode(userDataString));
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
      return prefs.getString(_emailid);
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

  Future<void> saveAuthStatus(String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authStatusKey, status);
      log.d('Auth status "$status" saved');
    } catch (e) {
      log.e('Error saving auth status: $e');
      rethrow;
    }
  }

  Future<void> saveEmailID(String emailid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailid, emailid);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authStatusKey);
    } catch (e) {
      log.e('Error getting auth status: $e');
      return null;
    }
  }

  Future<void> clearAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authStatusKey);
      log.d('Auth status cleared');
    } catch (e) {
      log.e('Error clearing auth status: $e');
    }
  }

  Future<bool> isAuthSuccess() async {
    try {
      return (await getAuthStatus()) == 'Success';
    } catch (e) {
      log.e('Error checking auth success: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await clearAllStorage();
      log.d('User logged out and data cleared');
    } catch (e) {
      log.e('Error during logout: $e');
      rethrow;
    }
  }

  Future<void> clearAllStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      log.d('All storage cleared');
    } catch (e) {
      log.e('Error clearing storage: $e');
    }
  }

  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'shared_preferences': {
          'logged_in': prefs.getBool(AppConfig.IsLoggedIn) ?? false,
          'auth_status': prefs.getString(_authStatusKey),
          'token':
              prefs.getString(AppConfig.AccessToken)?.substring(0, 20) ??
              'null',
          'user_id': prefs.getInt(AppConfig.UserId),
          'username': prefs.getString(AppConfig.Username),
          'employee_id': prefs.getInt(AppConfig.EmployeeId),
          'company_id': prefs.getInt(AppConfig.CompanyId),
        },
        'attendance': {
          'is_checked_in': prefs.getBool(_isCheckedInKey) ?? false,
          'is_checked_out': prefs.getBool(_isCheckedOutKey) ?? false,
          'check_in_time': prefs.getString(_checkInTimeKey),
          'check_out_time': prefs.getString(_checkOutTimeKey),
          'check_in_date': prefs.getString(_checkInDateKey),
        },
      };
    } catch (e) {
      log.e('Error getting debug info: $e');
      return {'error': e.toString()};
    }
  }
}
