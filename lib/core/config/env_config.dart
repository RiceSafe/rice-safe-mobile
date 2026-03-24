import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api';

  /// LINE Login channel ID from `.env`; null if unset or blank.
  static String? get lineChannelId {
    final v = dotenv.env['LINE_CHANNEL_ID']?.trim();
    if (v == null || v.isEmpty) return null;
    return v;
  }
}
