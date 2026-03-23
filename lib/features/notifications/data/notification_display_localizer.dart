import 'package:ricesafe_app/features/notifications/data/models/notification_api_models.dart';

/// แปลข้อความแจ้งเตือน outbreak จาก API (อังกฤษ) เป็นภาษาไทยทางการสำหรับแสดงในแอปเท่านั้น
class NotificationDisplayLocalizer {
  NotificationDisplayLocalizer._();

  static const _outbreakType = 'OUTBREAK_NEARBY';

  static final _titleEn = RegExp(
    r'^Disease\s+Alert:\s*(.+)\s*$',
    caseSensitive: false,
  );

  static const _bodyPrefix = 'A new case of ';
  static const _bodySuffix =
      ' has been diagnosed near your location. Please check your crops.';

  static String titleForDisplay(NotificationDto n) {
    if (n.type != _outbreakType) return n.title;
    final m = _titleEn.firstMatch(n.title.trim());
    if (m == null) return n.title;
    final name = m.group(1)!.trim();
    if (name.isEmpty) return n.title;
    return 'แจ้งเตือน: $name';
  }

  static String bodyForDisplay(NotificationDto n) {
    if (n.type != _outbreakType) return n.body;
    final disease = _parseEnglishOutbreakBody(n.body);
    if (disease == null) return n.body;
    return 'พบการวินิจฉัย $disease ใกล้แปลงของคุณ แนะนำให้ตรวจนาและเฝ้าระวังอาการ';
  }

  /// คืนชื่อโรคจากประโยคอังกฤษมาตรฐานของ backend เท่านั้น
  static String? _parseEnglishOutbreakBody(String raw) {
    final t = raw.trim();
    if (!t.startsWith(_bodyPrefix)) return null;
    if (!t.endsWith(_bodySuffix)) return null;
    final inner = t.substring(
      _bodyPrefix.length,
      t.length - _bodySuffix.length,
    ).trim();
    return inner.isEmpty ? null : inner;
  }
}
