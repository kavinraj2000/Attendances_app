import 'package:hrm/core/repo/localdb_repo.dart';
import 'package:hrm/screens/login/repo/login_repo.dart';
import 'package:logger/logger.dart';

class Api {
  static const String baseUrl = 'https://doc.roo.bi/hrmapi/';

  static Future<Map<String, String>> headers() async {
    final loginRepo = LoginRepo();
    final token = await loginRepo.getToken();

    Logger().d('AUTH TOKEN => $token');

    if (token == null || token.isEmpty) {
      throw Exception('Token missing');
    }

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', // ✅ FIXED
    };
  }
}
