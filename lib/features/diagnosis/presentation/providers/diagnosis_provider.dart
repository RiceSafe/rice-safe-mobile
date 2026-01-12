import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/network/dio_client.dart';
import 'package:ricesafe_app/features/diagnosis/data/data_sources/diagnosis_remote_source.dart';
import 'package:ricesafe_app/features/diagnosis/data/diagnosis_repository.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';

abstract class DiagnosisState {}

class DiagnosisInitial extends DiagnosisState {}

class DiagnosisLoading extends DiagnosisState {}

class DiagnosisSuccess extends DiagnosisState {
  final DiagnosisResult result;
  DiagnosisSuccess(this.result);
}

class DiagnosisError extends DiagnosisState {
  final String message;
  DiagnosisError(this.message);
}

final dioClientProvider = Provider((ref) => DioClient());

final diagnosisRemoteSourceProvider = Provider((ref) {
  return DiagnosisRemoteDataSource(ref.read(dioClientProvider));
});

final diagnosisRepositoryProvider = Provider((ref) {
  return DiagnosisRepository(ref.read(diagnosisRemoteSourceProvider));
});

final diagnosisProvider =
    StateNotifierProvider.autoDispose<DiagnosisNotifier, DiagnosisState>((ref) {
      return DiagnosisNotifier(ref.read(diagnosisRepositoryProvider));
    });

class DiagnosisNotifier extends StateNotifier<DiagnosisState> {
  final DiagnosisRepository repository;

  DiagnosisNotifier(this.repository) : super(DiagnosisInitial());

  Future<void> diagnoseDisease({
    required File image,
    required String description,
  }) async {
    state = DiagnosisLoading();

    final resultEither = await repository.diagnose(image, description);

    resultEither.fold(
      (failure) => state = DiagnosisError(failure.message),
      (success) => state = DiagnosisSuccess(success),
    );
  }

  void reset() {
    state = DiagnosisInitial();
  }
}
