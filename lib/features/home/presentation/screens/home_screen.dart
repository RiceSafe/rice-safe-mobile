import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/main.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ricesafe_app/features/outbreak/data/mock_outbreak_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Image.asset('assets/rice_icon.png'),
        ),
        title: const Text('หน้าหลัก'),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting Section
            const Text(
              'สวัสดี, ใบข้าว',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: riceSafeDarkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ตรวจสอบสุขภาพข้าวของคุณวันนี้',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Weather Widget
            _buildSectionTitle('สภาพอากาศวันนี้'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สุพรรณบุรี',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '32°C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ฟ้าโปร่ง (Sunny)',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.wb_sunny, color: Colors.amber, size: 48),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'ความชื้น 60%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Outbreak Map Widget
            _buildSectionTitle('สถานการณ์การระบาด'),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  // Switch to Outbreak Tab
                  GoRouter.of(context).go('/outbreak');
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 150,
                      child: IgnorePointer(
                        child: FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(15.8700, 100.9925),
                            initialZoom: 5.0,
                            interactionOptions: InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.ricesafe.app',
                            ),
                            MarkerLayer(
                              markers:
                                  mockOutbreaks.map((outbreak) {
                                    return Marker(
                                      point: LatLng(
                                        outbreak.latitude,
                                        outbreak.longitude,
                                      ),
                                      width: 12,
                                      height: 12,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: getSeverityColor(
                                            outbreak.severity,
                                          ),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'แผนที่การระบาด',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'เช็คพื้นที่เสี่ยงใกล้ตัวคุณ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: const Text(
                              'ความเสี่ยงสูง',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Daily Disease Knowledge
            _buildSectionTitle('โรคข้าวน่ารู้ประจำวัน'),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dailyDiseases.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final disease = _dailyDiseases[index];
                  return _buildDiseaseCard(
                    title: disease.title,
                    imagePath: disease.imagePath,
                    tag: disease.tag,
                    color: disease.color,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDiseaseCard({
    required String title,
    required String imagePath,
    required String tag,
    required Color color,
  }) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagePath,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          // Info Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} // End of HomeScreen class

class DiseaseCardData {
  final String title;
  final String imagePath;
  final String tag;
  final Color color;

  DiseaseCardData({
    required this.title,
    required this.imagePath,
    required this.tag,
    required this.color,
  });
}

final List<DiseaseCardData> _dailyDiseases = [
  DiseaseCardData(
    title: 'โรคไหม้\n(Rice Blast Disease)',
    imagePath: 'assets/mock/rice_blast_2.jpg',
    tag: 'ระบาดหนัก',
    color: Colors.red,
  ),
  DiseaseCardData(
    title: 'โรคใบจุดสีน้ำตาล\n(Brown Spot Disease)',
    imagePath: 'assets/mock/brown_spot_2.jpg',
    tag: 'เฝ้าระวัง',
    color: Colors.orange,
  ),
  DiseaseCardData(
    title: 'โรคขอบใบแห้ง\n(Leaf Blight Disease)',
    imagePath: 'assets/mock/leaf_blight_2.jpg',
    tag: 'ทั่วไป',
    color: Colors.blue,
  ),
];
