import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:ricesafe_app/features/auth/presentation/providers/auth_state.dart';
import 'package:ricesafe_app/features/home/data/models/weather_response.dart';
import 'package:ricesafe_app/features/home/presentation/providers/dashboard_provider.dart';
import 'package:ricesafe_app/features/home/presentation/providers/home_daily_diseases_provider.dart';
import 'package:ricesafe_app/features/home/presentation/screens/home_screen.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';
import 'package:ricesafe_app/features/outbreak/data/models/outbreak_api_model.dart';
import 'package:ricesafe_app/features/outbreak/data/outbreak_repository.dart';
import 'package:ricesafe_app/features/notifications/application/notification_providers.dart';
import 'package:ricesafe_app/features/outbreak/presentation/providers/outbreak_provider.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';

class _FakeHomeOutbreakRepository extends OutbreakRepository {
  _FakeHomeOutbreakRepository() : super(Dio(BaseOptions()));

  @override
  Future<List<OutbreakSummary>> listOutbreaks({
    required bool verifiedOnly,
    double? userLat,
    double? userLong,
    int limit = 0,
  }) async {
    return [
      OutbreakSummary(
        id: 'a',
        diseaseId: 'b',
        diseaseName: 'X',
        latitude: 14.0,
        longitude: 100.0,
        isActive: true,
        isVerified: true,
      ),
    ];
  }

  @override
  Future<OutbreakSummary> getById(
    String id, {
    double? userLat,
    double? userLong,
  }) async {
    throw UnimplementedError();
  }
}

class _TestFarmLocationNotifier extends FarmLocationNotifier {
  @override
  Future<LatLng?> build() async => const LatLng(14.0, 100.0);
}

class _HomeScreenMockAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _HomeScreenMockAuthNotifier() : super(AuthState());

  @override
  Future<void> loginWithEmailPassword(String email, String password) async {}

  @override
  Future<void> loginWithOAuth(String provider, String idToken) async {}

  @override
  Future<void> registerAndSignIn({
    required String username,
    required String email,
    required String password,
    String role = 'FARMER',
  }) async {}

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<bool> updateProfile({
    String? username,
    String? avatarFilePath,
  }) async =>
      true;

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async =>
      true;
}

void main() {
  testWidgets('HomeScreen displays greeting and sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => _HomeScreenMockAuthNotifier()),
          farmLocationProvider.overrideWith(_TestFarmLocationNotifier.new),
          weatherProvider.overrideWith((ref) async {
            return const WeatherResponse(
              locationName: 'สุพรรณบุรี',
              temperature: 32,
              condition: 'Clear',
              description: 'ฟ้าโปร่ง (Sunny)',
              humidity: 60,
              iconUrl: '',
            );
          }),
          outbreakRepositoryProvider.overrideWith(
            (ref) => _FakeHomeOutbreakRepository(),
          ),
          homeDailyDiseasesProvider.overrideWith((ref) async {
            return [
              LibraryDisease(
                id: 'd1',
                alias: '',
                name: 'โรคไหม้',
                category: 'เชื้อรา',
                description: 'ทดสอบ',
              ),
            ];
          }),
          notificationUnreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('สวัสดี, ใบข้าว'), findsOneWidget);
    expect(find.text('ตรวจสอบสุขภาพข้าวของคุณวันนี้'), findsOneWidget);

    expect(find.text('สภาพอากาศวันนี้'), findsOneWidget);
    expect(find.text('สุพรรณบุรี'), findsOneWidget);
    expect(find.text('32°C'), findsOneWidget);

    expect(find.text('สถานการณ์การระบาด'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('1 จุด'), findsOneWidget);

    expect(find.text('โรคข้าวน่ารู้ประจำวัน'), findsOneWidget);
    expect(find.text('โรคไหม้'), findsOneWidget);
  });
}
