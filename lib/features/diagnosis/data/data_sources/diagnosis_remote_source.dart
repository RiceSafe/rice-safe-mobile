import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ricesafe_app/core/network/dio_client.dart';
import 'package:ricesafe_app/core/error/exceptions.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';
import 'package:http_parser/http_parser.dart';

class DiagnosisRemoteDataSource {
  final DioClient dioClient;

  DiagnosisRemoteDataSource(this.dioClient);

  Future<DiagnosisResult> predictDisease(
    File imageFile,
    String description,
  ) async {
    const String endpoint = '/predict/';

    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      'description': description,
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    try {
      final response = await dioClient.dio.post(
        endpoint,
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

      if (response.statusCode == 200) {
        return DiagnosisResult.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to get prediction: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        String message = 'API Error: ${e.response?.statusCode}';
        if (data is Map && data.containsKey('detail')) {
          message = data['detail'].toString();
        }
        throw ServerException(message);
      }
      throw NetworkException(e.message ?? 'Network Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
