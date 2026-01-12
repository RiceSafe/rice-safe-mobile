import 'dart:io';

class DiagnosisResult {
  final String name;
  final String confidence;
  final String remedy;
  final String treatment;
  final String? diseaseSpecificImageUrl;
  final File? userUploadedImage;

  DiagnosisResult({
    required this.name,
    required this.confidence,
    required this.remedy,
    required this.treatment,
    this.diseaseSpecificImageUrl,
    this.userUploadedImage,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      name: json['prediction'] ?? 'N/A',
      confidence: json['confidence'] ?? 'N/A',
      remedy: json['remedy'] ?? 'ไม่มีข้อมูลวิธีการรักษา',
      treatment: json['treatment'] ?? 'ไม่มีข้อมูลการควบคุมดูแล',
      diseaseSpecificImageUrl: json['imageUrl'],
    );
  }

  DiagnosisResult copyWith({File? userUploadedImage}) {
    return DiagnosisResult(
      name: name,
      confidence: confidence,
      remedy: remedy,
      treatment: treatment,
      diseaseSpecificImageUrl: diseaseSpecificImageUrl,
      userUploadedImage: userUploadedImage ?? this.userUploadedImage,
    );
  }
}
