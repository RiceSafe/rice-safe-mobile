import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';

/// JSON maps aligned with backend `DiagnosisResponse` for mock / dev UI.
class DiagnosisMockFixtures {
  DiagnosisMockFixtures._();

  /// มีโรค + อาการ + การรักษา/ป้องกัน (ใกล้ `disease.Disease` จาก API)
  static Map<String, dynamic> withDisease({
    String diagnosisId = 'aaaaaaaa-bbbb-cccc-dddd-111111111111',
  }) {
    return {
      'diagnosis_id': diagnosisId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'prediction': 'blast',
      'info_message': 'พบความน่าจะเป็นสูง',
      'confidence': 0.925,
      'image_url': 'https://picsum.photos/seed/diagnosis-mock/800/600',
      'disease_result': {
        'id': 'd1111111-1111-1111-1111-111111111111',
        'alias': 'rice_blast',
        'name': 'โรคไหม้ (Rice Blast)',
        'category': 'fungal',
        'image_url': 'https://picsum.photos/seed/blast-disease/600/400',
        'description':
            'โรคเชื้อราที่พบบ่อยในนาข้าว เกิดจุดสีน้ำตาลแดงบนใบและกาบ',
        'spread_details': 'แพร่กระจายเร็วในช่วงอากาศชื้นและมีหมอก',
        'symptoms': [
          {
            'title': 'จุดใบไหม้',
            'description':
                'จุดวงรีสีน้ำตาลเข้มถึงแดง ขอบสีเหลือง มักที่ปลายใบ',
          },
          {
            'title': 'แผลคอข้าว',
            'description': 'รอยแผลสีน้ำตาลที่คอรวง อาจทำให้ร่วงได้',
          },
        ],
        'treatment': [
          {
            'title': 'สารเคมี',
            'description':
                'ใช้ไตรไซคลาโซลหรือคาซูกาไมซินตามคำแนะนำ กรมการข้าว',
          },
        ],
        'prevention': [
          {
            'title': 'พันธุ์ต้านทาน',
            'description': 'เลือกพันธุ์ที่เหมาะกับพื้นที่และระบายน้ำดี',
          },
          {
            'title': 'ปุ๋ย',
            'description': 'หลีกเลี่ยงไนโตรเจนเกินความจำเป็น',
          },
        ],
      },
    };
  }

  /// ไม่มี disease_result — ข้าวปกติ
  static Map<String, dynamic> healthyNormal({
    String diagnosisId = 'bbbbbbbb-bbbb-cccc-dddd-222222222222',
  }) {
    return {
      'diagnosis_id': diagnosisId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'prediction': 'normal',
      'info_message': 'จากภาพและคำอธิบาย ต้นข้าวดูแข็งแรงดี',
      'confidence': 0.91,
      'image_url': 'https://picsum.photos/seed/diagnosis-healthy/800/600',
    };
  }

  /// เลือก fixture ตามคำอธิบาย (สำหรับทดสอบหลายเคสใน mock)
  static Map<String, dynamic> pickForDescription(String description) {
    final d = description.toLowerCase();
    if (d.contains('normal') ||
        d.contains('ปกติ') ||
        d.contains('healthy') ||
        d.contains('แข็งแรง')) {
      return healthyNormal();
    }
    return withDisease();
  }

  /// แถวประวัติจำลอง — ตรง `HistoryResponse`
  static List<DiagnosisHistoryDto> mockHistoryRows() {
    final now = DateTime.now();
    return [
      DiagnosisHistoryDto(
        id: 'mock-hist-001',
        imageUrl: 'https://picsum.photos/seed/diag-h1/120/120',
        prediction: 'blast',
        diseaseName: 'โรคไหม้ (Rice Blast)',
        confidence: 92.5,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      DiagnosisHistoryDto(
        id: 'mock-hist-002',
        imageUrl: 'https://picsum.photos/seed/diag-h2/120/120',
        prediction: 'normal',
        diseaseName: '',
        confidence: 0.88,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      DiagnosisHistoryDto(
        id: 'mock-hist-003',
        imageUrl: '',
        prediction: 'not_clear',
        diseaseName: '',
        confidence: 0.42,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}
