import 'package:dio/dio.dart';
import 'package:ricesafe_app/core/network/dio_error_detail.dart';
import 'package:ricesafe_app/features/notifications/data/models/notification_api_models.dart';

class NotificationRepository {
  NotificationRepository(this._dio);

  final Dio _dio;

  static List<NotificationDto> _parseList(dynamic raw) {
    if (raw == null) return [];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => NotificationDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<NotificationDto>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/notifications',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.statusCode == 200) {
        return _parseList(response.data);
      }
      throw Exception('โหลดการแจ้งเตือนไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/notifications/unread-count',
      );
      if (response.statusCode == 200 && response.data != null) {
        final n = response.data!['unread_count'];
        if (n is int) return n;
        if (n is num) return n.toInt();
      }
      throw Exception('โหลดจำนวนการแจ้งเตือนไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _dio.put<dynamic>(
        '/notifications/$notificationId/read',
      );
      if (response.statusCode == 200) return;
      throw Exception('อัปเดตสถานะไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _dio.put<dynamic>('/notifications/read-all');
      if (response.statusCode == 200) return;
      throw Exception('อัปเดตสถานะไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  Future<NotificationSettingsDto> getSettings() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/settings/notifications',
      );
      if (response.statusCode == 200 && response.data != null) {
        return NotificationSettingsDto.fromJson(response.data!);
      }
      throw Exception('โหลดการตั้งค่าไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }

  /// Partial update — only include keys that are non-null.
  Future<NotificationSettingsDto> updateSettings({
    bool? enabled,
    double? radiusKm,
    bool? notifyNearby,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{};
    if (enabled != null) body['enabled'] = enabled;
    if (radiusKm != null) body['radius_km'] = radiusKm;
    if (notifyNearby != null) body['notify_nearby'] = notifyNearby;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;

    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/settings/notifications',
        data: body,
      );
      if (response.statusCode == 200 && response.data != null) {
        return NotificationSettingsDto.fromJson(response.data!);
      }
      throw Exception('บันทึกการตั้งค่าไม่สำเร็จ');
    } on DioException catch (e) {
      throw Exception(dioErrorDetail(e));
    }
  }
}
