import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:go_router/go_router.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/features/home/data/models/weather_response.dart';
import 'package:ricesafe_app/features/home/presentation/providers/dashboard_provider.dart';
import 'package:ricesafe_app/main.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ricesafe_app/features/home/presentation/providers/home_daily_diseases_provider.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';
import 'package:ricesafe_app/features/library/presentation/providers/disease_library_provider.dart';
import 'package:ricesafe_app/features/library/presentation/screens/library_detail_screen.dart';
import 'package:ricesafe_app/features/outbreak/presentation/outbreak_map_style.dart';
import 'package:ricesafe_app/features/outbreak/presentation/providers/outbreak_provider.dart';
import 'package:ricesafe_app/core/map/ricesafe_map_tiles.dart';
import 'package:ricesafe_app/core/widgets/app_bar_profile_button.dart';
import 'package:ricesafe_app/core/widgets/unread_notification_badge.dart';
import 'package:ricesafe_app/features/notifications/application/notification_providers.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final greetName = (user?.username.trim().isNotEmpty ?? false)
        ? user!.username.trim()
        : 'ใบข้าว';
    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final unreadCount = unreadAsync.valueOrNull ?? 0;

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
          UnreadNotificationBadge(
            unreadCount: unreadCount,
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: riceSafeGreen,
              tooltip: 'การแจ้งเตือน',
              onPressed: () {
                context.push('/notifications').then((_) {
                  ref.invalidate(notificationUnreadCountProvider);
                });
              },
            ),
          ),
          const AppBarProfileButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting Section
            Text(
              'สวัสดี, $greetName',
              style: const TextStyle(
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
            _HomeWeatherCard(ref: ref),
            const SizedBox(height: 24),

            // Outbreak Map Widget
            _buildSectionTitle('สถานการณ์การระบาด'),
            const SizedBox(height: 12),
            _HomeOutbreakPreviewCard(ref: ref),
            const SizedBox(height: 24),

            // Daily Disease Knowledge (API — no image until DB has image_url)
            _buildSectionTitle('โรคข้าวน่ารู้ประจำวัน'),
            const SizedBox(height: 12),
            _HomeDailyDiseasesSection(),
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

} // End of HomeScreen class

Widget _homeDiseaseImagePlaceholder() {
  return Container(
    color: Colors.grey[300],
    alignment: Alignment.center,
    child: const Icon(
      Icons.image_not_supported,
      color: Colors.grey,
    ),
  );
}

Color _homeCategoryColor(String category) {
  const map = {
    'เชื้อรา': Colors.orange,
    'แบคทีเรีย': Colors.blue,
    'ไวรัส': Colors.red,
    'fungal': Colors.orange,
    'bacterial': Colors.blue,
    'virus': Colors.red,
  };
  return map[category] ?? Colors.grey;
}

class _HomeDailyDiseasesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeDailyDiseasesProvider);

    return async.when(
      data: (items) {
        if (items.isEmpty) {
          return SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'ยังไม่มีข้อมูลโรคในคลังความรู้',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          );
        }
        return SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _HomeDailyDiseaseCard(disease: items[index]);
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) => SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userFacingMessage(
                  e,
                  contextFallback: 'โหลดข้อมูลโรคไม่สำเร็จ',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[800], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              TextButton(
                onPressed: () {
                  ref.invalidate(diseaseListProvider(''));
                  ref.invalidate(homeDailyDiseasesProvider);
                },
                child: const Text('ลองอีกครั้ง'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeDailyDiseaseCard extends StatelessWidget {
  const _HomeDailyDiseaseCard({required this.disease});

  final LibraryDisease disease;

  @override
  Widget build(BuildContext context) {
    final tagColor = _homeCategoryColor(disease.category);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => LibraryDetailScreen(diseaseId: disease.id),
          ),
        );
      },
      child: Container(
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 100,
                child: disease.imageUrl != null &&
                        disease.imageUrl!.isNotEmpty
                    ? Image.network(
                        disease.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => _homeDiseaseImagePlaceholder(),
                      )
                    : _homeDiseaseImagePlaceholder(),
              ),
            ),
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
                        color: tagColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        disease.category.isEmpty ? 'ทั่วไป' : disease.category,
                        style: TextStyle(
                          color: tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      disease.displayTitle,
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
      ),
    );
  }
}

class _HomeWeatherCard extends StatelessWidget {
  const _HomeWeatherCard({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider);

    return weatherAsync.when(
      loading: () => _weatherShell(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
      error: (err, _) => _weatherShell(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userFacingMessage(
                  err,
                  contextFallback: 'โหลดสภาพอากาศไม่สำเร็จ',
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref.invalidate(weatherProvider),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'ลองอีกครั้ง',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (weather) {
        if (weather == null) {
          return _weatherShell(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ยังไม่ได้ตั้งตำแหน่งแปลงนา',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ตั้งค่าแปลงนาเพื่อดูสภาพอากาศในพื้นที่ของคุณ',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () =>
                        GoRouter.of(context).push('/settings/farm-location'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                    ),
                    child: const Text('ไปตั้งค่าตำแหน่งแปลงนา'),
                  ),
                ],
              ),
            ),
          );
        }
        return _weatherDataLayout(context, weather);
      },
    );
  }

  Widget _weatherShell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _weatherDataLayout(BuildContext context, WeatherResponse w) {
    final subtitle = w.description.isNotEmpty ? w.description : w.condition;
    return _weatherShell(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    w.locationName.isNotEmpty ? w.locationName : 'พื้นที่ของคุณ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${w.temperature.round()}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (w.iconUrl.isNotEmpty)
                  Image.network(
                    w.iconUrl,
                    width: 56,
                    height: 56,
                    errorBuilder: (_, __, ___) => Icon(
                      _weatherIconForCondition(w.condition),
                      color: Colors.amber,
                      size: 48,
                    ),
                  )
                else
                  Icon(
                    _weatherIconForCondition(w.condition),
                    color: Colors.amber,
                    size: 48,
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ความชื้น ${w.humidity}%',
                        style: const TextStyle(
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
    );
  }

  IconData _weatherIconForCondition(String main) {
    final m = main.toLowerCase();
    if (m.contains('rain') || m.contains('drizzle')) {
      return Icons.grain;
    }
    if (m.contains('cloud')) return Icons.cloud;
    if (m.contains('snow')) return Icons.ac_unit;
    if (m.contains('thunder') || m.contains('storm')) {
      return Icons.thunderstorm;
    }
    if (m.contains('mist') || m.contains('fog') || m.contains('haze')) {
      return Icons.foggy;
    }
    return Icons.wb_sunny;
  }
}

class _HomeOutbreakPreviewCard extends StatelessWidget {
  const _HomeOutbreakPreviewCard({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final farmAsync = ref.watch(farmLocationProvider);
    final farm = farmAsync.valueOrNull;

    if (farm == null) {
      return Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ยังไม่ได้ตั้งตำแหน่งแปลงนา',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ตั้งค่าแปลงนาเพื่อดูสถานการณ์โรคระบาดในพื้นที่ของคุณ',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () =>
                    GoRouter.of(context).push('/settings/farm-location'),
                style: FilledButton.styleFrom(
                  backgroundColor: riceSafeGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ไปตั้งค่าตำแหน่งแปลงนา'),
              ),
            ],
          ),
        ),
      );
    }

    final query = ref.watch(homeOutbreakPreviewQueryProvider);
    final async = ref.watch(outbreakListProvider(query));

    final LatLng mapCenter = farm;
    final double mapZoom = 13.5;

    final outbreakMarkers = async.maybeWhen(
      data: (items) => items
          .map(
            (o) => Marker(
              point: LatLng(o.latitude, o.longitude),
              width: 12,
              height: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: outbreakMarkerColor(o),
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
            ),
          )
          .toList(),
      orElse: () => <Marker>[],
    );

    final farmMarkers = <Marker>[
      Marker(
        point: farm,
        width: 40,
        height: 40,
        alignment: Alignment.topCenter,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      ),
    ];

    final markers = [...outbreakMarkers, ...farmMarkers];

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          GoRouter.of(context).go('/outbreak');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120,
              child: IgnorePointer(
                child: FlutterMap(
                  key: ValueKey(
                    '${mapCenter.latitude}_${mapCenter.longitude}_$mapZoom',
                  ),
                  options: MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: mapZoom,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    ricesafeMapTileLayer(),
                    MarkerLayer(markers: markers),
                    ricesafeMapAttribution(
                      alignment: AttributionAlignment.bottomLeft,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'แผนที่การระบาด',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'หมุดแดง = แปลงนา · จุดสี = การระบาด',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  async.when(
                    data: (items) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        '${items.length} จุด',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    loading: () => const SizedBox(
                      width: 28,
                      height: 28,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Text(
                        'โหลดไม่สำเร็จ',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

