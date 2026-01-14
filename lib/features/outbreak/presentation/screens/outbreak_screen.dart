import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/main.dart';
import 'package:ricesafe_app/features/outbreak/data/mock_outbreak_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OutbreakScreen extends StatefulWidget {
  const OutbreakScreen({super.key});

  @override
  State<OutbreakScreen> createState() => _OutbreakScreenState();
}

class _OutbreakScreenState extends State<OutbreakScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LatLng mockUserLocation = const LatLng(13.7563, 100.5018); // Bangkok
  final Distance distance = const Distance();
  final MapController _mapController = MapController();
  double _currentZoom = 6.0;

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                GoRouter.of(context).push('/settings');
              },
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: riceSafeGreen,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
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
        children: [_buildMapTab(), _buildListTab()],
      ),
    );
  }

  Widget _buildMapTab() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(
              15.8700,
              100.9925,
            ), // Center of Thailand
            initialZoom: _currentZoom,
            onMapEvent: (evt) {
              if (evt is MapEventMove) {
                _currentZoom = evt.camera.zoom;
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ricesafe.app',
            ),
            MarkerLayer(
              markers: [
                // User Location Marker
                Marker(
                  point: mockUserLocation,
                  width: 80,
                  height: 80,
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Text(
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
                // Outbreak Markers
                ...mockOutbreaks.map((outbreak) {
                  return Marker(
                    point: LatLng(outbreak.latitude, outbreak.longitude),
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () => _showOutbreakDialog(context, outbreak),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: getSeverityColor(outbreak.severity),
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
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        // Zoom Controls
        Positioned(
          bottom: 20,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: "zoom_in",
                onPressed: () {
                  _currentZoom++;
                  _mapController.move(
                    _mapController.camera.center,
                    _currentZoom,
                  );
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: "zoom_out",
                onPressed: () {
                  _currentZoom--;
                  _mapController.move(
                    _mapController.camera.center,
                    _currentZoom,
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

  Widget _buildListTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockOutbreaks.length,
      itemBuilder: (context, index) {
        final outbreak = mockOutbreaks[index];
        final double dist = distance.as(
          LengthUnit.Kilometer,
          mockUserLocation,
          LatLng(outbreak.latitude, outbreak.longitude),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        color: getSeverityColor(
                          outbreak.severity,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: getSeverityColor(outbreak.severity),
                        ),
                      ),
                      child: Text(
                        getSeverityText(outbreak.severity),
                        style: TextStyle(
                          color: getSeverityColor(outbreak.severity),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
                    Text(
                      '${outbreak.district}, ${outbreak.province}',
                      style: const TextStyle(color: Colors.grey),
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
                      DateFormat('dd MMM yyyy').format(outbreak.date),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.directions_car,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dist.toStringAsFixed(1)} กม.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOutbreakDialog(BuildContext context, OutbreakLocation outbreak) {
    final double dist = distance.as(
      LengthUnit.Kilometer,
      mockUserLocation,
      LatLng(outbreak.latitude, outbreak.longitude),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(outbreak.diseaseName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('พื้นที่: ${outbreak.district}, ${outbreak.province}'),
                Text('ความรุนแรง: ${getSeverityText(outbreak.severity)}'),
                Text(
                  'วันที่: ${DateFormat('dd MMM yyyy').format(outbreak.date)}',
                ),
                const SizedBox(height: 10),
                Text('ระยะทาง: ${dist.toStringAsFixed(1)} กม.'),
              ],
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
