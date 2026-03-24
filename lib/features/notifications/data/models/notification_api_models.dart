/// Aligns with backend `internal/notification` JSON.
class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      referenceId: json['reference_id']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: _parseDate(json['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}

class NotificationSettingsDto {
  const NotificationSettingsDto({
    required this.userId,
    required this.enabled,
    required this.radiusKm,
    required this.notifyNearby,
    this.latitude,
    this.longitude,
  });

  final String userId;
  final bool enabled;
  final double radiusKm;
  final bool notifyNearby;
  final double? latitude;
  final double? longitude;

  factory NotificationSettingsDto.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsDto(
      userId: json['user_id']?.toString() ?? '',
      enabled: json['enabled'] == true,
      radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 0,
      notifyNearby: json['notify_nearby'] == true,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
