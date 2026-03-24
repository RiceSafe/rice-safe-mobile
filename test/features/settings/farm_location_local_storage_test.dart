import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ricesafe_app/features/settings/data/farm_location_local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('saveForUser and loadForUser round-trip per user', () async {
    const u1 = 'user-aaa';
    const u2 = 'user-bbb';

    expect(await FarmLocationLocalStorage.loadForUser(u1), isNull);
    expect(await FarmLocationLocalStorage.loadForUser(u2), isNull);

    await FarmLocationLocalStorage.saveForUser(
      u1,
      const LatLng(14.5, 100.2),
    );
    await FarmLocationLocalStorage.saveForUser(
      u2,
      const LatLng(16.0, 99.1),
    );

    final l1 = await FarmLocationLocalStorage.loadForUser(u1);
    final l2 = await FarmLocationLocalStorage.loadForUser(u2);
    expect(l1!.latitude, 14.5);
    expect(l1.longitude, 100.2);
    expect(l2!.latitude, 16.0);
    expect(l2.longitude, 99.1);
  });

  test('saveForUser null clears only that user', () async {
    const u1 = 'u1';
    const u2 = 'u2';
    await FarmLocationLocalStorage.saveForUser(u1, const LatLng(1, 2));
    await FarmLocationLocalStorage.saveForUser(u2, const LatLng(3, 4));
    await FarmLocationLocalStorage.saveForUser(u1, null);
    expect(await FarmLocationLocalStorage.loadForUser(u1), isNull);
    expect(await FarmLocationLocalStorage.loadForUser(u2), isNotNull);
  });

  test('empty userId does not persist', () async {
    await FarmLocationLocalStorage.saveForUser('', const LatLng(1, 2));
    expect(await FarmLocationLocalStorage.loadForUser(''), isNull);
  });

  test('clearLegacyGlobalKeys removes old global keys', () async {
    SharedPreferences.setMockInitialValues({
      'farm_latitude': 13.0,
      'farm_longitude': 100.0,
    });
    await FarmLocationLocalStorage.clearLegacyGlobalKeys();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('farm_latitude'), isNull);
    expect(prefs.getDouble('farm_longitude'), isNull);
  });
}
