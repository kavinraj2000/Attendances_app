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

  Future<LoginModel> requestAuth({
    required String email,
    required String password,
  }) async {
    try {
      final baseapi = Api.baseUrl;
      log.d('requestAuth:baseapi:$baseapi');
      final url = baseapi + Constants.api.verifyemail;
      log.d('requestAuth:url:$url');

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

      log.d('requestAuth:response:${response.body}');

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
}
