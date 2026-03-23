/// Aligns with backend `internal/outbreak` JSON (`OutbreakResponse`).
class OutbreakSummary {
  final String id;
  final String diseaseId;
  final String diseaseName;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final double? distance;
  final bool isActive;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OutbreakSummary({
    required this.id,
    required this.diseaseId,
    required this.diseaseName,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.distance,
    required this.isActive,
    required this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory OutbreakSummary.fromJson(Map<String, dynamic> json) {
    return OutbreakSummary(
      id: json['id'] as String,
      diseaseId: json['disease_id'] as String,
      diseaseName: json['disease_name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}
