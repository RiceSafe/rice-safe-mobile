import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ricesafe_app/features/home/data/dashboard_repository.dart';

void main() {
  group('DashboardRepository', () {
    test('getWeather parses 200 response', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'location_name': 'TestCity',
                  'temperature': 28.0,
                  'condition': 'Clouds',
                  'description': 'few clouds',
                  'humidity': 55,
                  'icon_url': 'http://openweathermap.org/img/wn/02d@2x.png',
                },
              ),
            );
          },
        ),
      );

      final repo = DashboardRepository(dio);
      final w = await repo.getWeather(latitude: 13.0, longitude: 100.0);
      expect(w.locationName, 'TestCity');
      expect(w.temperature, 28.0);
      expect(w.humidity, 55);
    });

    test('getWeather maps 503 to Thai message', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 503,
                data: {'error': 'Weather data is currently unavailable'},
              ),
            );
          },
        ),
      );

      final repo = DashboardRepository(dio);
      expect(
        () => repo.getWeather(latitude: 13.0, longitude: 100.0),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('บริการสภาพอากาศ'),
          ),
        ),
      );
    });
  });
}
