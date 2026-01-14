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
          name: "โรคไหม้ (Rice Blast Disease)",
          confidence: "98.5%",
          remedy:
              "การใช้สารเคมี: คลุกเมล็ดด้วย ไตรไซคลาโซล (tricyclazone) หรือ คาซูกาไมซิน (kasugamycin) หากพบการระบาดเกิน 5% ให้ฉีดพ่นตามอัตราที่ระบุ",
          treatment:
              "ใช้พันธุ์ต้านทาน: ภาคกลาง (สุพรรณบุรี 1, 60), ภาคเหนือ (สันปาตอง 1)\n"
              "การจัดการแปลง: หว่านเมล็ด 15-20 กก./ไร่ แบ่งแปลงให้ระบายอากาศดี\n"
              "ข้อควรระวัง: หลีกเลี่ยงปุ๋ยไนโตรเจนสูงเกิน 50 กก./ไร่ และระวังในช่วงอากาศเย็น/ชื้นจัด",
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
