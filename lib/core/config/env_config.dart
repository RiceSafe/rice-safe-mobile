import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
}
