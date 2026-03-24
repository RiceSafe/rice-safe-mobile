import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/notifications/data/notification_repository.dart';

void main() {
  group('NotificationRepository', () {
    test('getNotifications parses 200 array', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, contains('/notifications'));
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {
                    'id': 'n1',
                    'user_id': 'u1',
                    'title': 'T',
                    'body': 'B',
                    'type': 'OUTBREAK_NEARBY',
                    'reference_id': '00000000-0000-0000-0000-000000000001',
                    'is_read': false,
                    'created_at': '2025-01-15T10:30:00.000Z',
                  },
                ],
              ),
            );
          },
        ),
      );

      final repo = NotificationRepository(dio);
      final list = await repo.getNotifications();
      expect(list, hasLength(1));
      expect(list.first.id, 'n1');
      expect(list.first.isRead, false);
      expect(list.first.referenceId, '00000000-0000-0000-0000-000000000001');
      expect(list.first.createdAt.isUtc, true);
    });

    test('getUnreadCount parses unread_count', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'unread_count': 3},
              ),
            );
          },
        ),
      );

      final repo = NotificationRepository(dio);
      expect(await repo.getUnreadCount(), 3);
    });

    test('markAsRead calls PUT', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'PUT');
            expect(options.path, endsWith('/notifications/abc/read'));
            handler.resolve(
              Response(requestOptions: options, statusCode: 200),
            );
          },
        ),
      );

      final repo = NotificationRepository(dio);
      await repo.markAsRead('abc');
    });

    test('markAllAsRead calls PUT read-all', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'PUT');
            expect(options.path, endsWith('/notifications/read-all'));
            handler.resolve(
              Response(requestOptions: options, statusCode: 200),
            );
          },
        ),
      );

      final repo = NotificationRepository(dio);
      await repo.markAllAsRead();
    });

    test('getSettings parses response', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'user_id': 'u',
                  'enabled': true,
                  'radius_km': 5.5,
                  'notify_nearby': true,
                  'latitude': 13.0,
                  'longitude': 100.0,
                },
              ),
            );
          },
        ),
      );

      final repo = NotificationRepository(dio);
      final s = await repo.getSettings();
      expect(s.enabled, true);
      expect(s.radiusKm, 5.5);
      expect(s.notifyNearby, true);
      expect(s.latitude, 13.0);
      expect(s.longitude, 100.0);
    });

    test('updateSettings sends partial body', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'PUT');
            expect(options.data, {'enabled': false, 'radius_km': 10.0});
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'user_id': 'u',
                  'enabled': false,
                  'radius_km': 10.0,
                  'notify_nearby': true,
                },
              ),
            );
          },
        ),
      );

      final repo = NotificationRepository(dio);
      final s = await repo.updateSettings(enabled: false, radiusKm: 10.0);
      expect(s.enabled, false);
      expect(s.radiusKm, 10.0);
    });
  });
}
