import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/features/library/data/models/library_disease.dart';
import 'package:ricesafe_app/features/library/presentation/providers/disease_library_provider.dart';

/// Stable subset of the disease library for the home horizontal list (sorted by name).
const int kHomeDailyDiseasesMax = 8;

final homeDailyDiseasesProvider =
    FutureProvider<List<LibraryDisease>>((ref) async {
  final all = await ref.watch(diseaseListProvider('').future);
  if (all.isEmpty) return [];
  final sorted = [...all]..sort((a, b) => a.name.compareTo(b.name));
  return sorted.take(kHomeDailyDiseasesMax).toList();
});
