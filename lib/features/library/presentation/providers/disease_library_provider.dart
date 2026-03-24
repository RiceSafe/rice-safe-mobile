import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/network/dio_provider.dart';
import 'package:ricesafe_app/features/library/data/disease_repository.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';

final diseaseRepositoryProvider = Provider<DiseaseRepository>((ref) {
  return DiseaseRepository(ref.watch(dioProvider));
});

/// Categories from API (no "ทั้งหมด" — UI adds that).
final diseaseCategoriesProvider = FutureProvider<List<String>>((ref) async {
  return ref.read(diseaseRepositoryProvider).getCategories();
});

/// Empty [categoryKey] means all diseases.
final diseaseListProvider =
    FutureProvider.family<List<LibraryDisease>, String>((ref, categoryKey) {
  return ref.read(diseaseRepositoryProvider).listDiseases(
        category: categoryKey.isEmpty ? null : categoryKey,
      );
});

final diseaseDetailProvider =
    FutureProvider.family<LibraryDisease, String>((ref, id) {
  return ref.read(diseaseRepositoryProvider).getById(id);
});
