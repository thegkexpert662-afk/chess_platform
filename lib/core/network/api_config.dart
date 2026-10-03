import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'CHESS_API_URL',
    defaultValue: 'http://localhost:4001/api',
  );

  static String get resolvedBaseUrl => kIsWeb
      ? 'http://localhost:4001/api'
      : baseUrl == 'http://localhost:4001/api'
          ? 'http://10.0.2.2:4001/api'
          : baseUrl;
}
