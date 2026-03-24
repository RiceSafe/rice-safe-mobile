import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ricesafe_app/features/auth/presentation/screens/onboarding_farm_location_screen.dart';
import 'package:ricesafe_app/features/notifications/data/models/notification_api_models.dart';
import 'package:ricesafe_app/features/notifications/data/notification_repository.dart';
import 'package:ricesafe_app/features/notifications/application/notification_repository_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';
import 'package:ricesafe_app/features/settings/presentation/screens/farm_location_settings_screen.dart';

import '../../helpers/test_helpers.dart';

class _NullFarmLocationNotifier extends FarmLocationNotifier {
  @override
  Future<LatLng?> build() async => null;
}

class _FakeNotificationRepository extends NotificationRepository {
  _FakeNotificationRepository() : super(Dio(BaseOptions()));

  @override
  Future<NotificationSettingsDto> getSettings() async {
    return const NotificationSettingsDto(
      userId: 'test-user',
      enabled: true,
      radiusKm: 10,
      notifyNearby: true,
      latitude: null,
      longitude: null,
    );
  }

  @override
  Future<NotificationSettingsDto> updateSettings({
    bool? enabled,
    double? radiusKm,
    bool? notifyNearby,
    double? latitude,
    double? longitude,
  }) async =>
      getSettings();

  @override
  Future<List<NotificationDto>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<int> getUnreadCount() async => 0;

  @override
  Future<void> markAsRead(String notificationId) async {}

  @override
  Future<void> markAllAsRead() async {}
}

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    registerFallbackValue(const LatLng(0, 0));
    mockRouter = MockGoRouter();
    FarmLocationSettingsScreen.savedLocation = null;
    FarmLocationSettingsScreen.isOutbreakAlertEnabled = true;
    FarmLocationSettingsScreen.alertRadiusKm = 10;
    when(() => mockRouter.go(any())).thenReturn(null);
    when(() => mockRouter.push<LatLng>(any(), extra: any(named: 'extra')))
        .thenAnswer((_) async => null);
  });

  testWidgets('onboarding and settings farm location screens show map affordance',
      (tester) async {
    await pumpRouterApp(
      tester,
      home: const OnboardingFarmLocationScreen(),
      router: mockRouter,
      overrides: [
        farmLocationProvider.overrideWith(_NullFarmLocationNotifier.new),
        notificationRepositoryProvider.overrideWith(
          (ref) => _FakeNotificationRepository(),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('ตั้งค่าแปลงนาของคุณ'), findsOneWidget);
    expect(find.text('แตะเพื่อเลือกตำแหน่งแปลงนา'), findsOneWidget);
    expect(find.text('เปิดรับการแจ้งเตือน'), findsOneWidget);

    await pumpRouterApp(
      tester,
      home: const FarmLocationSettingsScreen(),
      router: mockRouter,
      overrides: [
        farmLocationProvider.overrideWith(_NullFarmLocationNotifier.new),
        notificationRepositoryProvider.overrideWith(
          (ref) => _FakeNotificationRepository(),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('ตั้งค่าฟาร์มและการแจ้งเตือน'), findsOneWidget);
    expect(find.text('ตำแหน่งแปลงนาของคุณ'), findsOneWidget);
    expect(find.text('แตะเพื่อเลือกตำแหน่งแปลงนา'), findsOneWidget);
  });
}
