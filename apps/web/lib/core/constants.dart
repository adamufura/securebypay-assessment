class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static const String tokenKey = 'access_token';
  static const String userKey = 'cached_user';

  static const List<String> phoneCountryCodes = [
    '+234',
    '+233',
    '+1',
    '+44',
    '+27',
  ];
}
