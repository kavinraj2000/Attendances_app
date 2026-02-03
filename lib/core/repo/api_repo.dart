import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/screens/login/repo/login_repo.dart';
import 'package:logger/logger.dart';

class Api {
  static const String baseUrl = 'https://doc.roo.bi/hrmapi/';

  static Future<Map<String, String>> headers() async {
    final loginRepo = PreferencesRepository();
    final token = await loginRepo.getToken();

    Logger().d('Api:$baseUrl::$token');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'token': token,
    };
  }
  
}
