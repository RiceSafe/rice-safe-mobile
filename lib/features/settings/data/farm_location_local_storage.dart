import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// เก็บพิกัดแปลงนาแยกตามบัญชีผู้ใช้ (ไม่ใช้คีย์เดียวทั้งเครื่อง)
class FarmLocationLocalStorage {
  FarmLocationLocalStorage._();

  /// คีย์เก่าก่อนรองรับหลายบัญชี — ลบเมื่อพบเพื่อไม่ให้รั่วข้าม user
  static const _legacyLat = 'farm_latitude';
  static const _legacyLng = 'farm_longitude';

  static String _latKey(String userId) => 'farm_latitude_$userId';
  static String _lngKey(String userId) => 'farm_longitude_$userId';

  /// ลบคีย์ global เดิม (ถ้ามี) ครั้งเดียวต่อการเรียก — ปลอดภัยเรียกซ้ำ
  static Future<void> clearLegacyGlobalKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyLat);
    await prefs.remove(_legacyLng);
  }

  static Future<LatLng?> loadForUser(String userId) async {
    if (userId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey(userId));
    final lng = prefs.getDouble(_lngKey(userId));
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  static Future<void> saveForUser(String userId, LatLng? location) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (location == null) {
      await prefs.remove(_latKey(userId));
      await prefs.remove(_lngKey(userId));
      return;
    }
    await prefs.setDouble(_latKey(userId), location.latitude);
    await prefs.setDouble(_lngKey(userId), location.longitude);
  }
}
