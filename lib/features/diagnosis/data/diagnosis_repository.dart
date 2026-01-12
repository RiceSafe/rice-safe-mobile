import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:ricesafe_app/core/error/failures.dart';
import 'package:ricesafe_app/core/error/exceptions.dart';
import 'package:ricesafe_app/features/diagnosis/data/data_sources/diagnosis_remote_source.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';

class DiagnosisRepository {
  final DiagnosisRemoteDataSource remoteDataSource;

  DiagnosisRepository(this.remoteDataSource);

  Future<Either<Failure, DiagnosisResult>> diagnose(
    File image,
    String description,
  ) async {
    // Mock Mode
    bool useMock = true;

    if (useMock) {
      await Future.delayed(const Duration(seconds: 2));
      return Right(
        DiagnosisResult(
          name: "Rice Blast (โรคไหม้)",
          confidence: "98.5%",
          remedy:
              "ใช้สารเคมี Tricyclazole 75% WP อัตรา 10-15 กรัมต่อน้ำ 20 ลิตร\nฉีดพ่นเมื่อพบการระบาด",
          treatment:
              "จัดการน้ำให้พอเหมาะ อย่าให้แห้ง\nหลีกเลี่ยงการใส่ปุ๋ยไนโตรเจนสูงเกินไป",
          diseaseSpecificImageUrl: null,
          userUploadedImage: image,
        ),
      );
    } else {
      try {
        final resultModel = await remoteDataSource.predictDisease(
          image,
          description,
        );
        final resultWithImage = resultModel.copyWith(userUploadedImage: image);
        return Right(resultWithImage);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }
  }
}
