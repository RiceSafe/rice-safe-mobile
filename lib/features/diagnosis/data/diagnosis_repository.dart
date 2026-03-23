import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ricesafe_app/core/error/exceptions.dart';
import 'package:ricesafe_app/core/error/failures.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:ricesafe_app/features/diagnosis/data/data_sources/diagnosis_remote_source.dart';
import 'package:ricesafe_app/features/diagnosis/data/diagnosis_mock_fixtures.dart';
import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_backend_parser.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';

class DiagnosisRepository {
  DiagnosisRepository(this.remoteDataSource);

  final DiagnosisRemoteDataSource remoteDataSource;

  static bool get _useMockDiagnosis {
    final v = dotenv.env['USE_MOCK_DIAGNOSIS']?.toLowerCase().trim();
    return v == 'true' || v == '1';
  }

  Future<Either<Failure, DiagnosisResult>> diagnose(
    File image,
    String description, {
    double? latitude,
    double? longitude,
  }) async {
    if (_useMockDiagnosis) {
      await Future.delayed(const Duration(seconds: 2));
      final fixture = DiagnosisMockFixtures.pickForDescription(description);
      final parsed = DiagnosisBackendParser.fromBackendJson(
        fixture,
        userUploadedImage: image,
      );
      return Right(parsed);
    }

    try {
      final resultModel = await remoteDataSource.diagnose(
        imageFile: image,
        description: description,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(resultModel);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          userFacingMessage(
            e,
            contextFallback: 'วินิจฉัยไม่สำเร็จ',
          ),
        ),
      );
    } on NetworkException catch (e) {
      return Left(
        NetworkFailure(
          userFacingMessage(
            e,
            contextFallback: 'วินิจฉัยไม่สำเร็จ',
          ),
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          userFacingMessage(
            e,
            contextFallback: 'วินิจฉัยไม่สำเร็จ',
          ),
        ),
      );
    }
  }

  Future<Either<Failure, List<DiagnosisHistoryDto>>> getHistory() async {
    if (_useMockDiagnosis) {
      return Right(DiagnosisMockFixtures.mockHistoryRows());
    }
    try {
      final list = await remoteDataSource.getHistory();
      return Right(list);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          userFacingMessage(
            e,
            contextFallback: 'โหลดประวัติไม่สำเร็จ',
          ),
        ),
      );
    } on NetworkException catch (e) {
      return Left(
        NetworkFailure(
          userFacingMessage(
            e,
            contextFallback: 'โหลดประวัติไม่สำเร็จ',
          ),
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          userFacingMessage(
            e,
            contextFallback: 'โหลดประวัติไม่สำเร็จ',
          ),
        ),
      );
    }
  }
}
