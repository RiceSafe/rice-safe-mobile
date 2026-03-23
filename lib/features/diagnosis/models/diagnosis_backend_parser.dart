import 'dart:io';

import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';

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
  /// Map only [not_rice], [not_clear], [other_diseases] (no DB row). [normal] uses
  /// [titleWhenNoDisease] before [diseaseName] so SQL `COALESCE(..., 'ปกติ/โรคอื่นๆ')` is not shown.
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

    final dr = json['disease_result'];
    if (dr is Map) {
      final dm = Map<String, dynamic>.from(dr);
      final name = dm['name']?.toString() ?? prediction;
      final diseaseImg = dm['image_url']?.toString();
      final symptoms = joinInfoSections(dm['symptoms']);
      var remedy = joinInfoSections(dm['treatment']);
      var treatment = joinInfoSections(dm['prevention']);
      final spread = dm['spread_details']?.toString().trim();
      if (spread != null && spread.isNotEmpty) {
        treatment = treatment.isEmpty
            ? spread
            : '$treatment\n\n$spread';
      }
      if (remedy.isEmpty && info.isNotEmpty) remedy = info;
      if (treatment.isEmpty) {
        treatment = 'ไม่มีข้อมูลการควบคุมดูแล';
      }

      return DiagnosisResult(
        name: name,
        confidence: confStr,
        remedy: remedy.isEmpty ? 'ไม่มีข้อมูลวิธีการรักษา' : remedy,
        treatment: treatment,
        diseaseSpecificImageUrl:
            (diseaseImg != null && diseaseImg.isNotEmpty) ? diseaseImg : null,
        userUploadedImage: userUploadedImage,
        diagnosisId: diagnosisId != null && diagnosisId.isNotEmpty
            ? diagnosisId
            : null,
        diagnosedAt: diagnosedAt,
        symptoms: symptoms,
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
    );
  }
}
