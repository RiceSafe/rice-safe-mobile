import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/notifications/application/notification_repository_provider.dart';
import 'package:ricesafe_app/features/notifications/data/models/notification_api_models.dart';
import 'package:ricesafe_app/features/notifications/data/notification_repository.dart';
import 'package:ricesafe_app/features/notifications/presentation/screens/notifications_screen.dart';

import '../../helpers/test_helpers.dart';

class _FakeNotificationRepository extends NotificationRepository {
  _FakeNotificationRepository() : super(Dio(BaseOptions()));

  @override
  Future<List<NotificationDto>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    return [
      NotificationDto(
        id: '1',
        userId: 'u',
        title: 'หัวข้อทดสอบ',
        body: 'เนื้อหา',
        type: 'TEST',
        referenceId: null,
        isRead: false,
        createdAt: DateTime.utc(2025, 3, 1, 12, 0),
      ),
    ];
  }

  @override
  Future<int> getUnreadCount() async => 1;

  @override
  Future<void> markAsRead(String notificationId) async {}

  @override
  Future<void> markAllAsRead() async {}
}

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
  });

  testWidgets('NotificationsScreen shows list from repository',
      (WidgetTester tester) async {
    await pumpRouterApp(
      tester,
      home: const NotificationsScreen(),
      router: mockRouter,
      overrides: [
        notificationRepositoryProvider.overrideWith(
          (ref) => _FakeNotificationRepository(),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('การแจ้งเตือน'), findsOneWidget);
    expect(find.text('หัวข้อทดสอบ'), findsOneWidget);
    expect(find.text('เนื้อหา'), findsOneWidget);
    expect(find.text('ยังไม่อ่าน'), findsOneWidget);
  });
}
