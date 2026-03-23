/// Aligns with backend `HistoryResponse`.
class DiagnosisHistoryDto {
  const DiagnosisHistoryDto({
    required this.id,
    required this.imageUrl,
    required this.prediction,
    required this.diseaseName,
    required this.confidence,
    required this.createdAt,
  });

  final String id;
  final String imageUrl;
  final String prediction;
  final String diseaseName;
  final double confidence;
  final DateTime? createdAt;

  factory DiagnosisHistoryDto.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final c = json['created_at'];
    if (c is String && c.isNotEmpty) {
      created = DateTime.tryParse(c);
    }
    return DiagnosisHistoryDto(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      prediction: json['prediction']?.toString() ?? '',
      diseaseName: json['disease_name']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      createdAt: created,
    );
  }
}
