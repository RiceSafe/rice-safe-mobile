import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_backend_parser.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';

void main() {
  group('DiagnosisBackendParser', () {
    test('fromBackendJson with disease_result maps treatment and prevention', () {
      final json = {
        'diagnosis_id': 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
        'created_at': '2025-03-22T10:00:00.000Z',
        'prediction': 'blast',
        'info_message': 'Disease detected',
        'confidence': 87.5,
        'image_url': 'https://example.com/user.jpg',
        'disease_result': {
          'name': 'โรคไหม้',
          'image_url': 'https://example.com/disease.jpg',
          'symptoms': [
            {'title': 'จุดสีน้ำตาล', 'description': 'บนใบแห้ง'},
          ],
          'treatment': [
            {'title': 'สารเคมี', 'description': 'ฉีดพ่นตามคำแนะนำ'},
          ],
          'prevention': [
            {'title': 'ป้องกัน', 'description': 'ใช้พันธุ์ต้านทาน'},
          ],
        },
      };

      final r = DiagnosisBackendParser.fromBackendJson(json);
      expect(r.name, 'โรคไหม้');
      expect(r.confidence, '87.5%');
      expect(r.diagnosisId, 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee');
      expect(r.diagnosedAt, isNotNull);
      expect(r.diagnosedAt!.toUtc().toIso8601String(),
          startsWith('2025-03-22T10:00:00'));
      expect(r.symptoms, contains('จุดสีน้ำตาล'));
      expect(r.symptoms, contains('บนใบแห้ง'));
      expect(r.diseaseSpecificImageUrl, 'https://example.com/disease.jpg');
      expect(r.remedy, contains('สารเคมี'));
      expect(r.remedy, contains('ฉีดพ่นตามคำแนะนำ'));
      expect(r.treatment, contains('ป้องกัน'));
      expect(DiagnosisBackendParser.formatConfidence(0.985), '98.5%');
    });

    test('fromBackendJson without disease uses Thai title for normal', () {
      final json = {
        'diagnosis_id': '11111111-2222-3333-4444-555555555555',
        'created_at': '2025-01-01T12:30:45.000Z',
        'prediction': 'normal',
        'info_message': 'Your rice plant is healthy.',
        'confidence': 0.95,
        'image_url': '',
      };
      final r = DiagnosisBackendParser.fromBackendJson(json);
      expect(r.name, 'ข้าวแข็งแรงดี');
      expect(r.confidence, '95.0%');
      expect(r.diagnosisId, '11111111-2222-3333-4444-555555555555');
      expect(r.symptoms, '');
    });

    test('displayTitleForHistory uses disease_name except non-disease predictions',
        () {
      expect(
        DiagnosisBackendParser.displayTitleForHistory(
          prediction: 'rice_blast',
          diseaseName: 'โรคไหม้',
        ),
        'โรคไหม้',
      );
      expect(
        DiagnosisBackendParser.displayTitleForHistory(
          prediction: 'brown_spot',
          diseaseName: 'ใบจุดสีน้ำตาล',
        ),
        'ใบจุดสีน้ำตาล',
      );
      expect(
        DiagnosisBackendParser.displayTitleForHistory(
          prediction: 'other_diseases',
          diseaseName: 'ปกติ/โรคอื่นๆ',
        ),
        'อื่น ๆ',
      );
      expect(
        DiagnosisBackendParser.displayTitleForHistory(
          prediction: 'not_clear',
          diseaseName: 'อะไรก็ได้',
        ),
        'ไม่ชัดเจน',
      );
      expect(
        DiagnosisBackendParser.displayTitleForHistory(
          prediction: 'not_rice',
          diseaseName: 'ปกติ/โรคอื่นๆ',
        ),
        'ไม่ใช่ใบข้าว',
      );
      expect(
        DiagnosisBackendParser.displayTitleForHistory(
          prediction: 'normal',
          diseaseName: 'ปกติ/โรคอื่นๆ',
        ),
        'ข้าวแข็งแรงดี',
      );
      expect(
        DiagnosisBackendParser.displayTitleForHistory(
          prediction: '',
          diseaseName: 'โรคไหม้',
        ),
        'โรคไหม้',
      );
      expect(
        DiagnosisBackendParser.displayTitleForHistory(
          prediction: '  ',
          diseaseName: '  จาก API  ',
        ),
        'จาก API',
      );
      expect(
        DiagnosisBackendParser.displayTitleForHistory(
          prediction: 'unknown_label',
          diseaseName: '',
        ),
        'unknown_label',
      );
    });

    test('DiagnosisResult.fromHistory uses disease name and maps prediction', () {
      final withName = DiagnosisHistoryDto(
        id: 'abc',
        imageUrl: 'https://x/y.jpg',
        prediction: 'rice_blast',
        diseaseName: 'โรคไหม้',
        confidence: 0.88,
        createdAt: DateTime.utc(2024, 6, 1, 8),
      );
      final r1 = DiagnosisResult.fromHistory(withName);
      expect(r1.name, 'โรคไหม้');
      expect(r1.confidence, '88.0%');
      expect(r1.diseaseSpecificImageUrl, 'https://x/y.jpg');
      expect(r1.diagnosisId, 'abc');
      expect(r1.symptoms, '');

      final noName = DiagnosisHistoryDto(
        id: 'd',
        imageUrl: '',
        prediction: 'normal',
        diseaseName: '',
        confidence: 1,
        createdAt: null,
      );
      final r2 = DiagnosisResult.fromHistory(noName);
      expect(r2.name, 'ข้าวแข็งแรงดี');

      final normalSqlFallback = DiagnosisHistoryDto(
        id: 'd2',
        imageUrl: '',
        prediction: 'normal',
        diseaseName: 'ปกติ/โรคอื่นๆ',
        confidence: 1,
        createdAt: null,
      );
      expect(DiagnosisResult.fromHistory(normalSqlFallback).name, 'ข้าวแข็งแรงดี');

      final notRice = DiagnosisHistoryDto(
        id: 'e',
        imageUrl: '',
        prediction: 'not_rice',
        diseaseName: '',
        confidence: 0.033,
        createdAt: null,
      );
      expect(DiagnosisResult.fromHistory(notRice).name, 'ไม่ใช่ใบข้าว');

      final other = DiagnosisHistoryDto(
        id: 'f',
        imageUrl: '',
        prediction: 'other_diseases',
        diseaseName: '',
        confidence: 0.5,
        createdAt: null,
      );
      expect(DiagnosisResult.fromHistory(other).name, 'อื่น ๆ');
    });

    test('DiagnosisResult.fromJson legacy flat still works', () {
      final r = DiagnosisResult.fromJson({
        'prediction': 'x',
        'confidence': '10%',
        'remedy': 'a',
        'treatment': 'b',
        'imageUrl': 'http://i',
      });
      expect(r.name, 'x');
      expect(r.diseaseSpecificImageUrl, 'http://i');
    });
  });
}
