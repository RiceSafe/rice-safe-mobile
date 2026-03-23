import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/features/notifications/application/notification_repository_provider.dart';
import 'package:ricesafe_app/features/notifications/data/models/notification_api_models.dart';
import 'package:ricesafe_app/features/settings/data/farm_location_bridge.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';
import 'package:ricesafe_app/main.dart';
import 'package:latlong2/latlong.dart';

import 'package:ricesafe_app/core/map/ricesafe_map_tiles.dart';
import 'package:flutter_map/flutter_map.dart';

class FarmLocationSettingsScreen extends ConsumerStatefulWidget {
  const FarmLocationSettingsScreen({super.key});

  static LatLng? get savedLocation => FarmLocationBridge.value;

  static set savedLocation(LatLng? v) => FarmLocationBridge.value = v;
  static bool isOutbreakAlertEnabled = true;
  static double alertRadiusKm = 10.0;

  @override
  ConsumerState<FarmLocationSettingsScreen> createState() =>
      _FarmLocationSettingsScreenState();
}

class _FarmLocationSettingsScreenState
    extends ConsumerState<FarmLocationSettingsScreen> {
  LatLng? _selectedLocation;
  bool _isOutbreakAlertEnabled = true;
  double _alertRadiusKm = 10;
  /// False until prefs + `GET /settings/notifications` have been merged.
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = FarmLocationSettingsScreen.savedLocation;
    _isOutbreakAlertEnabled = FarmLocationSettingsScreen.isOutbreakAlertEnabled;
    _alertRadiusKm = FarmLocationSettingsScreen.alertRadiusKm;
    Future.microtask(_bootstrapFromServerAndPrefs);
  }

  Future<void> _bootstrapFromServerAndPrefs() async {
    if (!mounted) return;
    LatLng? fromPrefs;
    try {
      fromPrefs = await ref.read(farmLocationProvider.future);
    } catch (_) {}

    NotificationSettingsDto? remote;
    try {
      final repo = ref.read(notificationRepositoryProvider);
      remote = await repo.getSettings();
    } catch (_) {
      // Offline or error — keep static / prefs below.
    }

    if (!mounted) return;

    if (remote != null) {
      LatLng? remoteLoc;
      if (remote.latitude != null && remote.longitude != null) {
        remoteLoc = LatLng(remote.latitude!, remote.longitude!);
      }
      // Sync remote location into provider to ensure single source of truth
      await ref.read(farmLocationProvider.notifier).setLocation(remoteLoc);
      fromPrefs = remoteLoc;
    }

    if (!mounted) return;
    setState(() {
      _selectedLocation = fromPrefs ??
          FarmLocationSettingsScreen.savedLocation ??
          _selectedLocation;
      if (remote != null) {
        _isOutbreakAlertEnabled = remote.enabled;
        _alertRadiusKm = remote.radiusKm.clamp(1.0, 50.0);
        FarmLocationSettingsScreen.isOutbreakAlertEnabled = remote.enabled;
        FarmLocationSettingsScreen.alertRadiusKm = _alertRadiusKm;
      }
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่าฟาร์มและการแจ้งเตือน'),
        centerTitle: true,
      ),
      body: !_initialized
          ? const Center(
              child: CircularProgressIndicator(color: riceSafeGreen),
            )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                      // กรณีที่ยังไม่ได้เลือกตำแหน่ง
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'คุณจะได้รับการแจ้งเตือนเมื่อมีรายงานโรคระบาดในรัศมีที่กำหนด',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],

            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          try {
                            await ref
                                .read(farmLocationProvider.notifier)
                                .setLocation(_selectedLocation);
                            final repo =
                                ref.read(notificationRepositoryProvider);
                            final loc = _selectedLocation;
                            await repo.updateSettings(
                              enabled: _isOutbreakAlertEnabled,
                              radiusKm: _alertRadiusKm,
                              notifyNearby: _isOutbreakAlertEnabled,
                              latitude: loc?.latitude,
                              longitude: loc?.longitude,
                            );
                            FarmLocationSettingsScreen.isOutbreakAlertEnabled =
                                _isOutbreakAlertEnabled;
                            FarmLocationSettingsScreen.alertRadiusKm =
                                _alertRadiusKm;

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('บันทึกการตั้งค่าสำเร็จ'),
                              ),
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  userFacingMessage(
                                    e,
                                    contextFallback: 'บันทึกการตั้งค่าไม่สำเร็จ',
                                  ),
                                ),
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: riceSafeGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'บันทึก',
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
