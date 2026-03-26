import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_backend_parser.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';

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
      expect(r.diseaseSpecificImageUrl, 'https://example.com/user.jpg');
      expect(r.remedy, contains('สารเคมี'));
      expect(r.remedy, contains('ฉีดพ่นตามคำแนะนำ'));
      expect(r.treatment, contains('ป้องกัน'));
      expect(r.careLookupAlias, 'blast');
      expect(r.apiInfoMessage, 'Disease detected');
      expect(DiagnosisBackendParser.formatConfidence(0.985), '98.5%');
    });

    test('fromBackendJson disease_result uses top-level image_url only; empty ok',
        () {
      final json = {
        'prediction': 'blast',
        'info_message': '',
        'confidence': 0.9,
        'image_url': '',
        'disease_result': {
          'name': 'โรคไหม้',
          'image_url': 'https://example.com/reference-only.jpg',
          'symptoms': [],
          'treatment': [],
          'prevention': [],
        },
      };
      final r = DiagnosisBackendParser.fromBackendJson(json);
      expect(r.diseaseSpecificImageUrl, isNull);
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
      expect(r.careLookupAlias, 'normal');
      expect(r.apiInfoMessage, 'Your rice plant is healthy.');
    });

    test('fromBackendJson not_clear sets apiInfoMessage for compact UI', () {
      final json = {
        'diagnosis_id': 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
        'created_at': '2025-03-22T10:00:00.000Z',
        'prediction': 'not_clear',
        'info_message': 'รูปภาพไม่ชัดเจน กรุณาถ่ายรูปใหม่อีกครั้ง',
        'confidence': 0.601,
        'image_url': 'https://example.com/u.jpg',
      };
      final r = DiagnosisBackendParser.fromBackendJson(json);
      expect(r.careLookupAlias, 'not_clear');
      expect(
        r.apiInfoMessage,
        'รูปภาพไม่ชัดเจน กรุณาถ่ายรูปใหม่อีกครั้ง',
      );
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
      expect(r1.careLookupAlias, 'rice_blast');
      expect(r1.remedy, '');
      expect(r1.treatment, '');

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
      expect(r2.careLookupAlias, 'normal');

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
      final rNotRice = DiagnosisResult.fromHistory(notRice);
      expect(rNotRice.name, 'ไม่ใช่ใบข้าว');
      expect(rNotRice.careLookupAlias, 'not_rice');
      expect(
        rNotRice.remedy,
        contains('สรุปจากประวัติการวินิจฉัย'),
      );

      final other = DiagnosisHistoryDto(
        id: 'f',
        imageUrl: '',
        prediction: 'other_diseases',
        diseaseName: '',
        confidence: 0.5,
        createdAt: null,
      );
      final rOther = DiagnosisResult.fromHistory(other);
      expect(rOther.name, 'อื่น ๆ');
      expect(rOther.careLookupAlias, 'other_diseases');
    });

    test('shouldFetchCareFromLibrary skips non-disease predictions and empty',
        () {
      expect(DiagnosisBackendParser.shouldFetchCareFromLibrary(null), false);
      expect(DiagnosisBackendParser.shouldFetchCareFromLibrary(''), false);
      expect(DiagnosisBackendParser.shouldFetchCareFromLibrary('  '), false);
      expect(DiagnosisBackendParser.shouldFetchCareFromLibrary('normal'), false);
      expect(
        DiagnosisBackendParser.shouldFetchCareFromLibrary('not_rice'),
        false,
      );
      expect(
        DiagnosisBackendParser.shouldFetchCareFromLibrary('not_clear'),
        false,
      );
      expect(
        DiagnosisBackendParser.shouldFetchCareFromLibrary('other_diseases'),
        false,
      );
      expect(DiagnosisBackendParser.shouldFetchCareFromLibrary('blast'), true);
      expect(
        DiagnosisBackendParser.shouldFetchCareFromLibrary(' rice_blast '),
        true,
      );
    });

    test('isNonDiseasePredictionAlias matches skip set', () {
      expect(DiagnosisBackendParser.isNonDiseasePredictionAlias(null), false);
      expect(DiagnosisBackendParser.isNonDiseasePredictionAlias(''), false);
      expect(DiagnosisBackendParser.isNonDiseasePredictionAlias('  '), false);
      expect(DiagnosisBackendParser.isNonDiseasePredictionAlias('blast'), false);
      expect(DiagnosisBackendParser.isNonDiseasePredictionAlias('not_clear'), true);
      expect(DiagnosisBackendParser.isNonDiseasePredictionAlias(' normal '), true);
    });

    test('careStringsFromLibraryDisease mirrors disease_result mapping', () {
      final d = LibraryDisease(
        id: '1',
        alias: 'blast',
        name: 'โรคไหม้',
        category: 'fungal',
        description: '',
        symptoms: const [
          LibraryInfoSection(title: 'จุด', description: 'บนใบ'),
        ],
        treatment: const [
          LibraryInfoSection(title: 'ยา', description: 'ฉีดพ่น'),
        ],
        prevention: const [
          LibraryInfoSection(title: 'ป้องกัน', description: 'พันธุ์ต้านทาน'),
        ],
        spreadDetails: 'แพ้ทางลม',
      );
      final c = DiagnosisBackendParser.careStringsFromLibraryDisease(d);
      expect(c.symptoms, contains('จุด'));
      expect(c.symptoms, contains('บนใบ'));
      expect(c.remedy, contains('ยา'));
      expect(c.remedy, contains('ฉีดพ่น'));
      expect(c.treatment, contains('ป้องกัน'));
      expect(c.treatment, contains('พันธุ์ต้านทาน'));
      expect(c.treatment, isNot(contains('แพ้ทางลม')));
    });

    test(
        'fromBackendJson disease_result ignores spread_details for treatment string',
        () {
      final jsonOnlySpread = {
        'prediction': 'blast',
        'info_message': '',
        'confidence': 0.9,
        'image_url': 'https://example.com/u.jpg',
        'disease_result': {
          'name': 'โรคทดสอบ',
          'symptoms': [],
          'treatment': [],
          'prevention': [],
          'spread_details': 'ข้อความการแพร่ระบาดไม่ควรอยู่ในการควบคุมดูแล',
        },
      };
      final rSpread = DiagnosisBackendParser.fromBackendJson(jsonOnlySpread);
      expect(rSpread.treatment, 'ไม่มีข้อมูลการควบคุมดูแล');
      expect(rSpread.treatment, isNot(contains('แพร่ระบาด')));

      final jsonMixed = {
        'prediction': 'blast',
        'info_message': '',
        'confidence': 0.9,
        'image_url': '',
        'disease_result': {
          'name': 'x',
          'symptoms': [],
          'treatment': [],
          'prevention': [
            {'title': 'ป้องกัน', 'description': 'ใช้พันธุ์ต้านทาน'},
          ],
          'spread_details': 'ลมและเมล็ด',
        },
      };
      final rMixed = DiagnosisBackendParser.fromBackendJson(jsonMixed);
      expect(rMixed.treatment, contains('ป้องกัน'));
      expect(rMixed.treatment, isNot(contains('ลมและเมล็ด')));
    });

    test('applyLibraryCareIfMatched updates result when alias matches', () {
      final h = DiagnosisHistoryDto(
        id: 'id',
        imageUrl: '',
        prediction: 'blast',
        diseaseName: 'โรคไหม้',
        confidence: 0.9,
        createdAt: null,
      );
      final base = DiagnosisResult.fromHistory(h);
      final lib = LibraryDisease(
        id: 'u',
        alias: 'blast',
        name: 'โรคไหม้',
        category: 'x',
        description: '',
        symptoms: const [
          LibraryInfoSection(title: 'S', description: 'sym'),
        ],
        treatment: const [
          LibraryInfoSection(title: 'R', description: 'rem'),
        ],
        prevention: const [
          LibraryInfoSection(title: 'T', description: 'ctrl'),
        ],
      );
      final merged = DiagnosisBackendParser.applyLibraryCareIfMatched(
        base,
        [lib],
      );
      expect(merged.symptoms, contains('S'));
      expect(merged.remedy, contains('R'));
      expect(merged.treatment, contains('T'));
      expect(merged.careLookupAlias, 'blast');
    });

    test('applyLibraryCareIfMatched leaves base when no alias match', () {
      final h = DiagnosisHistoryDto(
        id: 'id',
        imageUrl: '',
        prediction: 'blast',
        diseaseName: 'โรคไหม้',
        confidence: 0.9,
        createdAt: null,
      );
      final base = DiagnosisResult.fromHistory(h);
      final merged = DiagnosisBackendParser.applyLibraryCareIfMatched(
        base,
        [
          LibraryDisease(
            id: 'u',
            alias: 'other',
            name: 'อื่น',
            category: 'x',
            description: '',
          ),
        ],
      );
      expect(merged.symptoms, base.symptoms);
      expect(merged.remedy, base.remedy);
      expect(merged.treatment, base.treatment);
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
