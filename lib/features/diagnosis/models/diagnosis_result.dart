import 'dart:io';

import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_backend_parser.dart';

class DiagnosisResult {
  final String name;
  final String confidence;
  final String remedy;
  final String treatment;
  final String? diseaseSpecificImageUrl;
  final File? userUploadedImage;
  final String? diagnosisId;
  final DateTime? diagnosedAt;
  final String symptoms;

  /// History row [DiagnosisHistoryDto.prediction] for matching [LibraryDisease.alias] via GET /diseases.
  final String? careLookupAlias;

  /// `info_message` from `POST /diagnosis` (history API does not send this).
  final String? apiInfoMessage;

  DiagnosisResult({
    required this.name,
    required this.confidence,
    required this.remedy,
    required this.treatment,
    this.diseaseSpecificImageUrl,
    this.userUploadedImage,
    this.diagnosisId,
    this.diagnosedAt,
    this.symptoms = '',
    this.careLookupAlias,
    this.apiInfoMessage,
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

  /// From a history API row; care copy may be merged from GET /diseases on the result screen.
  factory DiagnosisResult.fromHistory(DiagnosisHistoryDto h) {
    final name = DiagnosisBackendParser.displayTitleForHistory(
      prediction: h.prediction,
      diseaseName: h.diseaseName,
    );
    final fetchCare =
        DiagnosisBackendParser.shouldFetchCareFromLibrary(h.prediction);
    return DiagnosisResult(
      name: name,
      confidence: DiagnosisBackendParser.formatConfidence(h.confidence),
      remedy:
          fetchCare
              ? ''
              : 'สรุปจากประวัติการวินิจฉัย — รายละเอียดเชิงลึกแสดงหลังวินิจฉัยในแอป',
      treatment:
          fetchCare
              ? ''
              : 'ดูข้อมูลเพิ่มเติมได้จากคลังความรู้ หรือวินิจฉัยใหม่ด้วยรูปปัจจุบัน',
      diseaseSpecificImageUrl: h.imageUrl.isNotEmpty ? h.imageUrl : null,
      userUploadedImage: null,
      diagnosisId: h.id.isNotEmpty ? h.id : null,
      diagnosedAt: h.createdAt,
      symptoms: '',
      careLookupAlias: h.prediction.trim().isEmpty ? null : h.prediction.trim(),
    );
  }

  DiagnosisResult copyWith({
    String? name,
    String? confidence,
    String? remedy,
    String? treatment,
    String? diseaseSpecificImageUrl,
    File? userUploadedImage,
    String? diagnosisId,
    DateTime? diagnosedAt,
    String? symptoms,
    String? careLookupAlias,
    String? apiInfoMessage,
  }) {
    return DiagnosisResult(
      name: name ?? this.name,
      confidence: confidence ?? this.confidence,
      remedy: remedy ?? this.remedy,
      treatment: treatment ?? this.treatment,
      diseaseSpecificImageUrl:
          diseaseSpecificImageUrl ?? this.diseaseSpecificImageUrl,
      userUploadedImage: userUploadedImage ?? this.userUploadedImage,
      diagnosisId: diagnosisId ?? this.diagnosisId,
      diagnosedAt: diagnosedAt ?? this.diagnosedAt,
      symptoms: symptoms ?? this.symptoms,
      careLookupAlias: careLookupAlias ?? this.careLookupAlias,
      apiInfoMessage: apiInfoMessage ?? this.apiInfoMessage,
    );
  }
}
