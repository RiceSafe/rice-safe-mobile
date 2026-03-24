import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_token_provider.dart';
import 'package:ricesafe_app/features/notifications/application/notification_repository_provider.dart';
import 'package:ricesafe_app/features/settings/data/farm_location_bridge.dart';
import 'package:ricesafe_app/features/settings/data/farm_location_local_storage.dart';

/// โหลด/บันทึกพิกัดแปลงนา **ตามบัญชี** + sync [FarmLocationBridge]
class FarmLocationNotifier extends AsyncNotifier<LatLng?> {
  /// ใช้ user จาก Hive (หลีกเลี่ยง import วนกับ auth_state)
  String? _currentUserId() {
    final token = ref.read(authTokenProvider);
    if (token == null || token.isEmpty) return null;
    final u = ref.read(authLocalStorageProvider).readUser();
    if (u == null || u.id.isEmpty) return null;
    return u.id;
  }

  @override
  Future<LatLng?> build() async {
    await FarmLocationLocalStorage.clearLegacyGlobalKeys();

    final userId = _currentUserId();
    if (userId == null) {
      FarmLocationBridge.value = null;
      return null;
    }

    // แหล่งความจริงต่อ user: API ก่อน แล้วค่อย cache ตาม userId
    try {
      final remote = await ref.read(notificationRepositoryProvider).getSettings();
      if (remote.latitude != null && remote.longitude != null) {
        final ll = LatLng(remote.latitude!, remote.longitude!);
        await FarmLocationLocalStorage.saveForUser(userId, ll);
        FarmLocationBridge.value = ll;
        return ll;
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('FarmLocationNotifier: remote settings load failed: $e');
        debugPrintStack(stackTrace: st);
      }
    }

    final cached = await FarmLocationLocalStorage.loadForUser(userId);
    FarmLocationBridge.value = cached;
    return cached;
  }

  Future<void> setLocation(LatLng? value) async {
    state = const AsyncLoading();
    final userId = _currentUserId();
    if (userId != null) {
      await FarmLocationLocalStorage.saveForUser(userId, value);
    }
    FarmLocationBridge.value = value;
    state = AsyncData(value);
  }
}

final farmLocationProvider =
    AsyncNotifierProvider<FarmLocationNotifier, LatLng?>(
  FarmLocationNotifier.new,
);
