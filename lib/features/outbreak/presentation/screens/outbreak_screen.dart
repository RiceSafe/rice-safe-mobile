import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/core/widgets/app_bar_profile_button.dart';
import 'package:ricesafe_app/core/map/ricesafe_map_tiles.dart';
import 'package:ricesafe_app/main.dart';
import 'package:ricesafe_app/features/outbreak/data/models/outbreak_api_model.dart';
import 'package:ricesafe_app/features/outbreak/presentation/outbreak_map_style.dart';
import 'package:ricesafe_app/features/outbreak/presentation/providers/outbreak_provider.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

(String label, Color fg, Color bg) outbreakStatusChipStyle(OutbreakSummary o) {
  if (!o.isActive) {
    return ('ปิดการระบาด', Colors.grey.shade800, Colors.grey.shade200);
  }
  if (o.isVerified) {
    return ('ยืนยันแล้ว', Colors.green.shade800, Colors.green.shade100);
  }
  return ('รอยืนยัน', Colors.orange.shade900, Colors.orange.shade100);
}

double distanceKmForOutbreak(
  OutbreakSummary o,
  LatLng user,
  Distance distance,
) {
  if (o.distance != null) return o.distance!;
  return distance.as(
    LengthUnit.Kilometer,
    user,
    LatLng(o.latitude, o.longitude),
  );
}

/// Pin + API distance use saved farm location; returns null if unset.
LatLng? outbreakMapUserPin(AsyncValue<LatLng?> farmAsync) {
  return farmAsync.valueOrNull;
}

class OutbreakScreen extends ConsumerStatefulWidget {
  const OutbreakScreen({super.key});

  @override
  ConsumerState<OutbreakScreen> createState() => _OutbreakScreenState();
}

class _OutbreakScreenState extends ConsumerState<OutbreakScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Distance _distance = const Distance();
  final MapController _mapController = MapController();
  double? _currentZoom;
  bool _onlyVerified = true;

  void _retry() {
    final farmAsync = ref.read(farmLocationProvider);
    final pin = outbreakMapUserPin(farmAsync);
    ref.invalidate(
      outbreakListProvider(
        OutbreakListQuery(
          verifiedOnly: _onlyVerified,
          userLat: pin?.latitude,
          userLong: pin?.longitude,
          limit: 0,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farmAsync = ref.watch(farmLocationProvider);
    final userLocation = outbreakMapUserPin(farmAsync);
    final listQuery = OutbreakListQuery(
      verifiedOnly: _onlyVerified,
      userLat: userLocation?.latitude,
      userLong: userLocation?.longitude,
      limit: 0,
    );
    final listAsync = ref.watch(outbreakListProvider(listQuery));

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/rice_icon.png'),
        ),
        title: const Text(
          'แจ้งเตือนการระบาด',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: const [AppBarProfileButton()],
        bottom: TabBar(
          controller: _tabController,
          labelColor: riceSafeGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: riceSafeGreen,
          tabs: const [
            Tab(text: 'แผนที่', icon: Icon(Icons.map)),
            Tab(text: 'รายการ', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          listAsync.when(
            data: (items) => _buildMapTab(context, items, userLocation),
            loading: () => _buildMapTabLoading(userLocation),
            error: (e, _) => _buildErrorBody(
              userFacingMessage(
                e,
                contextFallback: 'โหลดข้อมูลการระบาดไม่สำเร็จ',
              ),
            ),
          ),
          listAsync.when(
            data: (items) => _buildListTab(context, items, userLocation),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildErrorBody(
              userFacingMessage(
                e,
                contextFallback: 'โหลดข้อมูลการระบาดไม่สำเร็จ',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBody(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[800]),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _retry,
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTabLoading(LatLng? userLocation) {
    return Stack(
      children: [
        _buildMapShell(userLocation: userLocation, markers: const []),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildMapShell({
    required LatLng? userLocation,
    required List<Marker> markers,
  }) {
    final center = userLocation ?? const LatLng(15.8700, 100.9925);
    final zoom = _currentZoom ?? (userLocation != null ? 10.0 : 5.0);

    return Stack(
      children: [
        FlutterMap(
          key: ValueKey('${center.latitude}_${center.longitude}_$zoom'),
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            onMapEvent: (evt) {
              if (evt is MapEventMove) {
                _currentZoom = evt.camera.zoom;
              }
            },
          ),
          children: [
            ricesafeMapTileLayer(),
            MarkerLayer(
              markers: [
                if (userLocation != null)
                  Marker(
                    point: userLocation,
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_pin_circle,
                          color: Colors.blue,
                          size: 40,
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'คุณ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ...markers,
              ],
            ),
            ricesafeMapAttribution(
              alignment: AttributionAlignment.bottomLeft,
            ),
          ],
        ),
        Positioned(
          top: 20,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'เฉพาะที่ตรวจสอบแล้ว',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _onlyVerified,
                  onChanged: (value) {
                    setState(() {
                      _onlyVerified = value;
                    });
                  },
                  activeThumbColor: riceSafeGreen,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'outbreak_zoom_in',
                onPressed: () {
                  _currentZoom = (_currentZoom ?? 5.0) + 1;
                  _mapController.move(
                    _mapController.camera.center,
                    _currentZoom!,
                  );
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'outbreak_zoom_out',
                onPressed: () {
                  _currentZoom = (_currentZoom ?? 5.0) - 1;
                  _mapController.move(
                    _mapController.camera.center,
                    _currentZoom!,
                  );
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.remove, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapTab(
    BuildContext context,
    List<OutbreakSummary> items,
    LatLng? userLocation,
  ) {
    final markers = items.map((outbreak) {
      return Marker(
        point: LatLng(outbreak.latitude, outbreak.longitude),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () => _showOutbreakDialog(context, outbreak, userLocation),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.location_on,
                    color: outbreakMarkerColor(outbreak),
                    size: 40,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ],
              ),
              if (outbreak.isVerified)
                Positioned(
                  top: 0,
                  right: 20,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                )
              else
                Positioned(
                  top: 0,
                  right: 20,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.help,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();

    return _buildMapShell(userLocation: userLocation, markers: markers);
  }

  Widget _buildListTab(
    BuildContext context,
    List<OutbreakSummary> items,
    LatLng? userLocation,
  ) {
    return Column(
      children: [
        if (userLocation == null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange[50],
            width: double.infinity,
            child: const Text(
              'ยังไม่ได้ตั้งตำแหน่งแปลงนา (ไม่สามารถคำนวณระยะทางได้)',
              style: TextStyle(color: Colors.orange, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'เฉพาะที่ตรวจสอบแล้ว',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _onlyVerified,
                onChanged: (value) {
                  setState(() {
                    _onlyVerified = value;
                  });
                },
                activeThumbColor: riceSafeGreen,
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'ไม่มีข้อมูลการระบาด',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final outbreak = items[index];
                    final dist = userLocation != null
                        ? distanceKmForOutbreak(
                            outbreak,
                            userLocation,
                            _distance,
                          )
                        : null;
                    final chip = outbreakStatusChipStyle(outbreak);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () =>
                            _showOutbreakDialog(context, outbreak, userLocation),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      outbreak.diseaseName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: chip.$3,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: outbreakMarkerColor(outbreak),
                                      ),
                                    ),
                                    child: Text(
                                      chip.$1,
                                      style: TextStyle(
                                        color: chip.$2,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (outbreak.isVerified)
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'ตรวจสอบแล้วโดยผู้เชี่ยวชาญ',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.help,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'รอการตรวจสอบ',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'พิกัด: ${outbreak.coordinatesLabel}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    outbreak.createdAt != null
                                        ? DateFormat('dd/MM/yyyy HH:mm').format(
                                            outbreak.createdAt!.toLocal(),
                                          )
                                        : '—',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (dist != null) ...[
                                    const Spacer(),
                                    Icon(
                                      Icons.directions_car,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${dist.toStringAsFixed(1)} กม.',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showOutbreakDialog(
    BuildContext context,
    OutbreakSummary outbreak,
    LatLng? userLocation,
  ) {
    final dist = userLocation != null
        ? distanceKmForOutbreak(outbreak, userLocation, _distance)
        : null;
    final created = outbreak.createdAt;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(outbreak.diseaseName),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('พิกัด: ${outbreak.coordinatesLabel}'),
              const SizedBox(height: 4),
              Text(
                outbreak.isActive
                    ? 'สถานะ: กำลังระบาด'
                    : 'สถานะ: ปิดการระบาด',
              ),
              const SizedBox(height: 4),
              Text(
                created != null
                    ? 'วันที่: ${DateFormat('dd/MM/yyyy HH:mm').format(created.toLocal())}'
                    : 'วันที่: —',
              ),
              const SizedBox(height: 4),
              if (dist != null)
                Text('ระยะทาง: ${dist.toStringAsFixed(1)} กม.')
              else
                const Text('ระยะทาง: ไม่สามารถคำนวณได้ (ยังไม่ได้ตั้งแปลงนา)'),
              if (outbreak.isVerified) ...[
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'ตรวจสอบแล้วโดยผู้เชี่ยวชาญ',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.help, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'รอการตรวจสอบ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              if (outbreak.imageUrl != null &&
                  outbreak.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    outbreak.imageUrl!,
                    height: 200,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.broken_image, color: Colors.grey),
                            SizedBox(height: 4),
                            Text('ไม่สามารถโหลดรูปภาพได้'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}
