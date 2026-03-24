import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ricesafe_app/features/diagnosis/data/data_sources/diagnosis_remote_source.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: 'BASE_URL=http://localhost:8080/api\n');
  });

  test('diagnose parses 200 DiagnosisResponse', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.path, contains('/diagnosis'));
          expect(options.method, 'POST');
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'diagnosis_id': '11111111-1111-1111-1111-111111111111',
                'disease_result': null,
                'prediction': 'normal',
                'info_message': 'OK',
                'confidence': 99.0,
                'image_url': '',
                'created_at': '2025-01-01T00:00:00Z',
              },
            ),
          );
        },
      ),
    );

    final dir = Directory.systemTemp.createTempSync('diag_test_');
    final f = File('${dir.path}/x.jpg');
    f.writeAsBytesSync([1, 2, 3]);

    final src = DiagnosisRemoteDataSource(dio);
    final r = await src.diagnose(
      imageFile: f,
      description: 'test',
      latitude: 13.0,
      longitude: 100.0,
    );

    expect(r.name, 'ข้าวแข็งแรงดี');
    expect(r.diagnosisId, '11111111-1111-1111-1111-111111111111');
    expect(r.symptoms, '');
    expect(r.userUploadedImage?.path, f.path);
    await dir.delete(recursive: true);
  });

  test('getHistory parses list', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: [
                {
                  'id': 'a',
                  'image_url': 'http://x',
                  'prediction': 'p',
                  'disease_name': 'โรค',
                  'confidence': 80.0,
                  'created_at': '2025-01-01T00:00:00Z',
                },
              ],
            ),
          );
        },
      ),
    );

    final src = DiagnosisRemoteDataSource(dio);
    final list = await src.getHistory();
    expect(list, hasLength(1));
    expect(list.first.diseaseName, 'โรค');
  });
}
