import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/core/map/ricesafe_map_tiles.dart';
import 'package:ricesafe_app/main.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerScreen({super.key, this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _currentCenter;
  LatLng? _pinnedLocation;
  final MapController _mapController = MapController();
  double _currentZoom = 13.0;
  bool _resolvingMyLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _currentCenter = widget.initialLocation!;
      _pinnedLocation = widget.initialLocation!;
    } else {
      _currentCenter = const LatLng(13.7563, 100.5018);
    }
  }

  Future<void> _goToMyGpsLocation() async {
    setState(() => _resolvingMyLocation = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง'),
            ),
          );
        }
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'ตำแหน่งถูกปฏิเสธถาวร กรุณาเปิดในการตั้งค่าแอป',
              ),
              action: SnackBarAction(
                label: 'ตั้งค่า',
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }

      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('กรุณาเปิดบริการตำแหน่ง (GPS)'),
              action: SnackBarAction(
                label: 'เปิด',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _currentCenter = ll;
        _pinnedLocation = ll;
        _currentZoom = 15.0;
      });
      _mapController.move(ll, _currentZoom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userFacingMessage(
                e,
                contextFallback: 'ไม่สามารถดึงตำแหน่งปัจจุบันได้',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _resolvingMyLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกตำแหน่งแปลงนา'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_pinnedLocation != null) {
                Navigator.pop(context, _pinnedLocation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('กรุณาแตะบนแผนที่เพื่อปักหมุดตำแหน่งแปลงนา'),
                  ),
                );
              }
            },
            child: Text(
              'ยืนยัน',
              style: TextStyle(
                color: _pinnedLocation != null ? riceSafeGreen : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: _currentZoom,
              onTap: (tapPosition, point) {
                setState(() {
                  _pinnedLocation = point;
                });
              },
              onPositionChanged: (MapCamera position, bool hasGesture) {
                if (hasGesture) {
                  _currentCenter = position.center;
                  _currentZoom = position.zoom;
                }
              },
            ),
            children: [
              ricesafeMapTileLayer(),
              if (_pinnedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pinnedLocation!,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ricesafeMapAttribution(
                alignment: AttributionAlignment.bottomLeft,
              ),
            ],
          ),
          Positioned(
            bottom: 32,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
                      _mapController.move(_currentCenter, _currentZoom);
                    });
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
                      _mapController.move(_currentCenter, _currentZoom);
                    });
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'my_location_picker',
                  onPressed: _resolvingMyLocation ? null : _goToMyGpsLocation,
                  backgroundColor: Colors.white,
                  child: _resolvingMyLocation
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: riceSafeGreen,
                          ),
                        )
                      : const Icon(Icons.my_location, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
