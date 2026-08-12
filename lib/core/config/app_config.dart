import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:4000/api/v1';

  static String get environment => dotenv.env['APP_ENV'] ?? 'development';
}
