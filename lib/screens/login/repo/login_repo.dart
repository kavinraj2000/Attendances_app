import 'dart:convert';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/login_model.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class LoginRepo {
  final log = Logger();

  final pref = PreferencesRepository();

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
              await pref.saveUserData(loginModel.data!);
              log.d('User data saved to SharedPreferences');
            } catch (e) {
              log.e('Error saving user to SharedPreferences: $e');
            }
          }
          if (loginModel.token != null) {
            await pref.saveToken(loginModel.token!);
            log.d('Token saved to SharedPreferences');
          }

          if (loginModel.userId != null) {
            await pref.saveUserId(loginModel.userId!);
            log.d('User ID saved to SharedPreferences');
          }
          await pref.setLoggedIn(true);
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
}
