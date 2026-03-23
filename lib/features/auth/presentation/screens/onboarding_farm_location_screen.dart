import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/main.dart';
import 'package:latlong2/latlong.dart';

import 'package:ricesafe_app/core/map/ricesafe_map_tiles.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:ricesafe_app/features/auth/onboarding/register_onboarding_state.dart';
import 'package:ricesafe_app/features/notifications/application/notification_repository_provider.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';
import 'package:ricesafe_app/features/settings/presentation/screens/farm_location_settings_screen.dart';

class OnboardingFarmLocationScreen extends ConsumerStatefulWidget {
  const OnboardingFarmLocationScreen({
    super.key,
    this.commitRegisterProfile = true,
  });

  /// When false (post-OAuth onboarding), skip [RegisterOnboardingState.commitProfileFromPending].
  final bool commitRegisterProfile;

  @override
  ConsumerState<OnboardingFarmLocationScreen> createState() =>
      _OnboardingFarmLocationScreenState();
}

class _OnboardingFarmLocationScreenState
    extends ConsumerState<OnboardingFarmLocationScreen> {
  LatLng? _selectedLocation;
  late bool _isOutbreakAlertEnabled;
  late double _alertRadiusKm;

  @override
  void initState() {
    super.initState();
    _selectedLocation = FarmLocationSettingsScreen.savedLocation;
    _isOutbreakAlertEnabled = FarmLocationSettingsScreen.isOutbreakAlertEnabled;
    _alertRadiusKm = FarmLocationSettingsScreen.alertRadiusKm;
    Future.microtask(() async {
      if (!mounted) return;
      
      // Try to get from API first to be consistent with Settings screen
      try {
        final remote = await ref.read(notificationRepositoryProvider).getSettings();
        if (remote.latitude != null && remote.longitude != null) {
          final remoteLoc = LatLng(remote.latitude!, remote.longitude!);
          await ref.read(farmLocationProvider.notifier).setLocation(remoteLoc);
          if (mounted) {
            setState(() {
              _selectedLocation = remoteLoc;
              _isOutbreakAlertEnabled = remote.enabled;
              _alertRadiusKm = remote.radiusKm.clamp(1.0, 50.0);
              FarmLocationSettingsScreen.isOutbreakAlertEnabled = remote.enabled;
              FarmLocationSettingsScreen.alertRadiusKm = _alertRadiusKm;
            });
          }
          return;
        }
      } catch (_) {
        // Fallback to prefs if API fails
      }

      final fromPrefs = await ref.read(farmLocationProvider.future);
      if (mounted) setState(() => _selectedLocation ??= fromPrefs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่าแปลงนาของคุณ'),
        centerTitle: true,
        automaticallyImplyLeading: false, // ซ่อนปุ่ม Back เพราะเป็น Flow ต่อเนื่อง
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'ระบุตำแหน่งแปลงนาเพื่อรับการแจ้งเตือนที่แม่นยำ',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            // Map Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ตำแหน่งแปลงนาของคุณ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (_selectedLocation != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'พิกัด: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(color: riceSafeGreen, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final result = await GoRouter.of(context).push<LatLng>('/map-picker', extra: _selectedLocation);
                if (result != null) {
                  setState(() {
                    _selectedLocation = result;
                  });
                }
              },
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[300],
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_selectedLocation != null)
                      // แสดงแผนที่จริงแบบย่อส่วน
                      AbsorbPointer( // ป้องกันไม่ให้เลื่อนแผนที่ในหน้านี้
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: _selectedLocation!,
                            initialZoom: 14.0,
                          ),
                          children: [
                            ricesafeMapTileLayer(),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.topCenter,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                            ricesafeMapAttribution(
                              alignment: AttributionAlignment.bottomLeft,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_location_alt_outlined,
                            size: 48,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'แตะเพื่อเลือกตำแหน่งแปลงนา',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            if (_selectedLocation == null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'คุณยังไม่ได้ตั้งค่าตำแหน่งแปลงนา',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'แตะแผนที่เพื่อเปลี่ยนตำแหน่งแปลงนาของคุณ',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            const Divider(height: 32),

            // Notification Settings
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'การแจ้งเตือนโรคระบาด',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('เปิดรับการแจ้งเตือน'),
              subtitle: const Text('รับการแจ้งเตือนเมื่อพบโรคระบาดใกล้แปลงนา'),
              value: _isOutbreakAlertEnabled,
              activeThumbColor: riceSafeGreen,
              onChanged: (value) {
                setState(() {
                  _isOutbreakAlertEnabled = value;
                });
              },
            ),

            if (_isOutbreakAlertEnabled) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('รัศมีการแจ้งเตือน'),
                    Text(
                      '${_alertRadiusKm.toInt()} กม.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: riceSafeGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Slider(
                value: _alertRadiusKm,
                min: 1,
                max: 50,
                divisions: 49,
                activeColor: riceSafeGreen,
                label: '${_alertRadiusKm.toInt()} กม.',
                onChanged: (value) {
                  setState(() {
                    _alertRadiusKm = value;
                  });
                },
              ),
            ],

            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // อย่า setLocation(null) — จะลบ prefs ทำให้เปิดแอปใหม่ไม่มีพิกัด
                    if (_selectedLocation != null) {
                      await ref
                          .read(farmLocationProvider.notifier)
                          .setLocation(_selectedLocation);
                    }
                    FarmLocationSettingsScreen.isOutbreakAlertEnabled =
                        _isOutbreakAlertEnabled;
                    FarmLocationSettingsScreen.alertRadiusKm = _alertRadiusKm;

                    try {
                      final loc = _selectedLocation;
                      await ref.read(notificationRepositoryProvider).updateSettings(
                            enabled: _isOutbreakAlertEnabled,
                            radiusKm: _alertRadiusKm,
                            notifyNearby: _isOutbreakAlertEnabled,
                            latitude: loc?.latitude,
                            longitude: loc?.longitude,
                          );
                    } catch (_) {
                      // ยังให้เข้า home ได้ถ้า sync server ล้มเหลว
                    }

                    if (widget.commitRegisterProfile) {
                      RegisterOnboardingState.commitProfileFromPending();
                    }

                    if (!context.mounted) return;
                    GoRouter.of(context).go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: riceSafeGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'เริ่มต้นใช้งาน',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
