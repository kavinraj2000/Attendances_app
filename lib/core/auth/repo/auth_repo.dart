import 'dart:convert';

import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/login_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AuthRepo {
  final log = Logger();

  final PreferencesRepository pref;
  AuthRepo(this.pref);

  Future<LoginModel> requestAuth({required String email}) async {
    try {
      final baseapi = Api.baseUrl;
      log.d('requestAuth:baseapi:$baseapi');
      final url = baseapi + Constants.api.verifyEMAIL;
      log.d('requestAuth:url:$url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "requestname": "verify_otp",
          "data": {"email": email},
        }),
      );

      log.d('requestAuth:response:${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final AuthModel = LoginModel.fromJson(data);

        if (AuthModel.success == true) {
          await pref.saveAuthStatus('Success');
          log.d('Auth status "Success" saved to SharedPreferences');
        }
        if (AuthModel.data?.emailId != null) {
          await pref.saveEmailID(AuthModel.data!.emailId!);
          log.d('Email ID saved: ${AuthModel.data!.emailId}');
        }

        return AuthModel;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (response.statusCode == 404) {
        throw Exception('Auth endpoint not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later');
      } else {
        throw Exception('Auth failed: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Auth failed: ${e.toString()}');
    }
  }

  Future<LoginModel> verfifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final baseapi = Api.baseUrl;
      log.d('verfifyOTP:baseapi:$baseapi');
      final url = baseapi + Constants.api.otpCHECK;
      log.d('verfifyOTP:url:$url');
      log.d('verfifyOTP:email:$email');
      log.d('verfifyOTP:otp:$otp');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "requestname": "verify_otp",
          "data": {"email": email, "otp": otp},
        }),
      );

      log.d('verfifyOTP:response:${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final AuthModel = LoginModel.fromJson(data);

        if (AuthModel.success == true && AuthModel.token != null) {
          if (AuthModel.data != null) {
            try {
              await pref.saveUserData(AuthModel.data!);
              log.d('User data saved to SharedPreferences');
            } catch (e) {
              log.e('Error saving user to SharedPreferences: $e');
            }
          }

          if (AuthModel.token != null) {
            await pref.saveToken(AuthModel.token!);
            log.d('Token saved to SharedPreferences');
          }

          if (AuthModel.userId != null) {
            await pref.saveUserId(AuthModel.userId!);
            log.d('User ID saved to SharedPreferences');
          }

          await pref.setLoggedIn(true);
          log.d('Auth status set to true');

          await pref.saveAuthStatus('Success');
          log.d('Auth status "Success" saved to SharedPreferences');
        }

        return AuthModel;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (response.statusCode == 404) {
        throw Exception('Auth endpoint not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later');
      } else {
        throw Exception('Auth failed: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Auth failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await pref.clearAuthStatus();
    await pref.setLoggedIn(false);
    await pref.clearAllData();

    log.d('User logged out and all data cleared');
  }
}
