import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/network/dio_provider.dart';
import 'package:ricesafe_app/features/diagnosis/data/data_sources/diagnosis_remote_source.dart';
import 'package:ricesafe_app/features/diagnosis/data/diagnosis_repository.dart';
import 'package:ricesafe_app/features/diagnosis/data/models/diagnosis_history_dto.dart';
import 'package:ricesafe_app/features/diagnosis/models/diagnosis_result.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';

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

final diagnosisRemoteSourceProvider = Provider((ref) {
  return DiagnosisRemoteDataSource(ref.watch(dioProvider));
});

final diagnosisRepositoryProvider = Provider((ref) {
  return DiagnosisRepository(ref.read(diagnosisRemoteSourceProvider));
});

final diagnosisProvider =
    StateNotifierProvider.autoDispose<DiagnosisNotifier, DiagnosisState>((ref) {
  return DiagnosisNotifier(ref);
});

class DiagnosisNotifier extends StateNotifier<DiagnosisState> {
  DiagnosisNotifier(this._ref) : super(DiagnosisInitial());

  final Ref _ref;

  Future<void> diagnoseDisease({
    required File image,
    required String description,
  }) async {
    state = DiagnosisLoading();

    double? lat;
    double? lon;
    try {
      final loc = await _ref.read(farmLocationProvider.future);
      lat = loc?.latitude;
      lon = loc?.longitude;
    } catch (_) {}

    final resultEither = await _ref.read(diagnosisRepositoryProvider).diagnose(
          image,
          description,
          latitude: lat,
          longitude: lon,
        );

    resultEither.fold(
      (failure) => state = DiagnosisError(failure.message),
      (success) {
        _ref.invalidate(diagnosisHistoryProvider);
        state = DiagnosisSuccess(success);
      },
    );
  }

  void reset() {
    state = DiagnosisInitial();
  }
}

final diagnosisHistoryProvider =
    FutureProvider.autoDispose<List<DiagnosisHistoryDto>>((ref) async {
  final repo = ref.watch(diagnosisRepositoryProvider);
  final result = await repo.getHistory();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
