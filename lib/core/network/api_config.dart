class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'CHESS_API_URL',
    defaultValue: 'http://10.0.2.2:4001/api',
  );
}
