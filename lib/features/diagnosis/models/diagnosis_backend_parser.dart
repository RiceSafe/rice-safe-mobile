import 'dart:io';

import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';

/// Maps RiceSafe `POST /diagnosis` JSON ([DiagnosisResponse]) to [DiagnosisResult].
class DiagnosisBackendParser {
  DiagnosisBackendParser._();

  static String formatConfidence(dynamic raw) {
    if (raw == null) return '—';
    if (raw is num) {
      final v = raw.toDouble();
      final pct = (v >= 0 && v <= 1.0) ? v * 100 : v;
      return '${pct.toStringAsFixed(1)}%';
    }
    return raw.toString();
  }

  /// Same layout as API JSON arrays for [joinInfoSections].
  static String joinLibraryInfoSections(List<LibraryInfoSection> sections) {
    if (sections.isEmpty) return '';
    final maps = sections
        .map(
          (s) => <String, dynamic>{
            'title': s.title,
            'description': s.description,
          },
        )
        .toList();
    return joinInfoSections(maps);
  }

  /// Maps library disease (GET /diseases) to the same strings as [fromBackendJson] disease_result.
  static ({String symptoms, String remedy, String treatment})
  careStringsFromLibraryDisease(LibraryDisease d) {
    final symptoms = joinLibraryInfoSections(d.symptoms);
    var remedy = joinLibraryInfoSections(d.treatment);
    var treatment = joinLibraryInfoSections(d.prevention);
    if (treatment.isEmpty) {
      treatment = 'ไม่มีข้อมูลการควบคุมดูแล';
    }
    if (remedy.isEmpty) {
      remedy = 'ไม่มีข้อมูลวิธีการรักษา';
    }
    return (symptoms: symptoms, remedy: remedy, treatment: treatment);
  }

  static const Set<String> _careFetchSkipPredictions = {
    'not_rice',
    'not_clear',
    'other_diseases',
    'normal',
  };

  static bool shouldFetchCareFromLibrary(String? careLookupAlias) {
    if (careLookupAlias == null) return false;
    final a = careLookupAlias.trim();
    if (a.isEmpty) return false;
    return !_careFetchSkipPredictions.contains(a);
  }

  /// True when [careLookupAlias] is a non-disease prediction (no care section below image).
  static bool isNonDiseasePredictionAlias(String? careLookupAlias) {
    if (careLookupAlias == null) return false;
    final a = careLookupAlias.trim();
    if (a.isEmpty) return false;
    return _careFetchSkipPredictions.contains(a);
  }

  static DiagnosisResult applyLibraryCareIfMatched(
    DiagnosisResult base,
    List<LibraryDisease> diseases,
  ) {
    final alias = base.careLookupAlias;
    if (alias == null || alias.isEmpty) return base;
    final a = alias.trim();
    for (final d in diseases) {
      if (d.alias.trim() == a) {
        final c = careStringsFromLibraryDisease(d);
        return base.copyWith(
          remedy: c.remedy,
          treatment: c.treatment,
          symptoms: c.symptoms,
        );
      }
    }
    return base;
  }

  static String joinInfoSections(dynamic raw) {
    if (raw == null) return '';
    if (raw is! List) return '';
    final buf = StringBuffer();
    for (final item in raw) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final t = m['title']?.toString().trim() ?? '';
      final d = m['description']?.toString().trim() ?? '';
      if (t.isNotEmpty) {
        buf.writeln(t);
      }
      if (d.isNotEmpty) {
        buf.writeln(d);
      }
      if (t.isNotEmpty || d.isNotEmpty) buf.writeln();
    }
    return buf.toString().trim();
  }

  static DateTime? parseCreatedAt(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static String titleWhenNoDisease(String prediction, String infoMessage) {
    switch (prediction) {
      case 'not_rice':
        return 'ไม่ใช่ใบข้าว';
      case 'not_clear':
        return 'ภาพไม่ชัดหรือความมั่นใจต่ำ';
      case 'normal':
        return 'ข้าวแข็งแรงดี';
      case 'other_diseases':
        return 'ปกติ/โรคอื่นๆ';
      default:
        if (infoMessage.isNotEmpty) return infoMessage;
        return prediction.isEmpty ? 'ผลการวินิจฉัย' : prediction;
    }
  }

  /// Predictions with no `diseases` row — API may send a SQL fallback for `disease_name`.
  static String _historyTitleNonDisease(String prediction) {
    switch (prediction.trim()) {
      case 'not_rice':
        return 'ไม่ใช่ใบข้าว';
      case 'not_clear':
        return 'ไม่ชัดเจน';
      case 'other_diseases':
        return 'อื่น ๆ';
      default:
        return '';
    }
  }

  /// History list: use `disease_name` from API (`d.name` when joined) for real diseases.
  static String displayTitleForHistory({
    required String prediction,
    required String diseaseName,
  }) {
    final p = prediction.trim();
    final nonDisease = _historyTitleNonDisease(p);
    if (nonDisease.isNotEmpty) {
      return nonDisease;
    }
    if (p == 'normal') {
      return titleWhenNoDisease('normal', '');
    }
    final d = diseaseName.trim();
    if (d.isNotEmpty) {
      return d;
    }
    if (p.isNotEmpty) {
      return titleWhenNoDisease(p, '');
    }
    return titleWhenNoDisease('', '');
  }

  static DiagnosisResult fromBackendJson(
    Map<String, dynamic> json, {
    File? userUploadedImage,
  }) {
    final prediction = json['prediction']?.toString() ?? '';
    final info = json['info_message']?.toString() ?? '';
    final confStr = formatConfidence(json['confidence']);
    final topImageUrl = json['image_url']?.toString();
    final diagnosisId = json['diagnosis_id']?.toString();
    final diagnosedAt = parseCreatedAt(json['created_at']);

    final careLookupAlias =
        prediction.trim().isEmpty ? null : prediction.trim();
    final apiInfoMessage = info.trim().isEmpty ? null : info.trim();

    final dr = json['disease_result'];
    if (dr is Map) {
      final dm = Map<String, dynamic>.from(dr);
      final name = dm['name']?.toString() ?? prediction;
      final symptoms = joinInfoSections(dm['symptoms']);
      var remedy = joinInfoSections(dm['treatment']);
      var treatment = joinInfoSections(dm['prevention']);
      if (remedy.isEmpty && info.isNotEmpty) remedy = info;
      if (treatment.isEmpty) {
        treatment = 'ไม่มีข้อมูลการควบคุมดูแล';
      }

      final userPhotoUrl =
          topImageUrl != null && topImageUrl.isNotEmpty ? topImageUrl : null;

      return DiagnosisResult(
        name: name,
        confidence: confStr,
        remedy: remedy.isEmpty ? 'ไม่มีข้อมูลวิธีการรักษา' : remedy,
        treatment: treatment,
        diseaseSpecificImageUrl: userPhotoUrl,
        userUploadedImage: userUploadedImage,
        diagnosisId: diagnosisId != null && diagnosisId.isNotEmpty
            ? diagnosisId
            : null,
        diagnosedAt: diagnosedAt,
        symptoms: symptoms,
        careLookupAlias: careLookupAlias,
        apiInfoMessage: apiInfoMessage,
      );
    }

    final name = titleWhenNoDisease(prediction, info);
    final showUploadedNetwork =
        topImageUrl != null && topImageUrl.isNotEmpty;

    return DiagnosisResult(
      name: name,
      confidence: confStr,
      remedy: info.isNotEmpty ? info : 'ไม่มีข้อมูลเพิ่มเติม',
      treatment: prediction == 'normal'
          ? 'รักษาสุขภาพแปลงและสังเกตอาการเป็นประจำ'
          : (info.isNotEmpty ? info : ''),
      diseaseSpecificImageUrl: showUploadedNetwork ? topImageUrl : null,
      userUploadedImage: userUploadedImage,
      diagnosisId: diagnosisId != null && diagnosisId.isNotEmpty
          ? diagnosisId
          : null,
      diagnosedAt: diagnosedAt,
      symptoms: '',
      careLookupAlias: careLookupAlias,
      apiInfoMessage: apiInfoMessage,
    );
  }
}
