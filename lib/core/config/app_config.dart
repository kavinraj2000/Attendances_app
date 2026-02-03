class AppConfig {
  AppConfig();

  static const Duration apiTimeout = Duration(seconds: 30);
  static const String appName = 'HRM App';
  static const String appVersion = '1.0.0';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const int itemsPerPage = 20;
  static const int maxRetries = 3;
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
   static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';
}
