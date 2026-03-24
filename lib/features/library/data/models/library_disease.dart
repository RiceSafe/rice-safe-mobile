/// Aligns with backend `internal/disease` JSON (public library API).
class LibraryInfoSection {
  final String title;
  final String description;

  const LibraryInfoSection({
    required this.title,
    required this.description,
  });

  factory LibraryInfoSection.fromJson(Map<String, dynamic> json) {
    return LibraryInfoSection(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class LibraryDisease {
  final String id;
  final String alias;
  final String name;
  final String category;
  final String? imageUrl;
  final String description;
  final String? spreadDetails;
  final List<String> matchWeather;
  final List<LibraryInfoSection> symptoms;
  final List<LibraryInfoSection> prevention;
  final List<LibraryInfoSection> treatment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LibraryDisease({
    required this.id,
    required this.alias,
    required this.name,
    required this.category,
    this.imageUrl,
    required this.description,
    this.spreadDetails,
    this.matchWeather = const [],
    this.symptoms = const [],
    this.prevention = const [],
    this.treatment = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory LibraryDisease.fromJson(Map<String, dynamic> json) {
    return LibraryDisease(
      id: json['id'] as String,
      alias: json['alias'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String? ?? '',
      spreadDetails: json['spread_details'] as String?,
      matchWeather: _stringList(json['match_weather']),
      symptoms: _sections(json['symptoms']),
      prevention: _sections(json['prevention']),
      treatment: _sections(json['treatment']),
      createdAt: _tryParseDate(json['created_at']),
      updatedAt: _tryParseDate(json['updated_at']),
    );
  }

  /// Text for list cards (single line friendly).
  String get displayTitle => name.replaceAll('\n', ' ').trim();

  static List<String> _stringList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).toList();
  }

  static List<LibraryInfoSection> _sections(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((e) => LibraryInfoSection.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
