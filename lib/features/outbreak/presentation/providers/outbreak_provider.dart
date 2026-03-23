import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/network/dio_provider.dart';
import 'package:ricesafe_app/features/outbreak/data/models/outbreak_api_model.dart';
import 'package:ricesafe_app/features/outbreak/data/outbreak_repository.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';

final outbreakRepositoryProvider = Provider<OutbreakRepository>((ref) {
  return OutbreakRepository(ref.watch(dioProvider));
});

/// Uses saved farm coordinates when available.
final homeOutbreakPreviewQueryProvider = Provider<OutbreakListQuery>((ref) {
  final farmAsync = ref.watch(farmLocationProvider);
  final farm = farmAsync.valueOrNull;
  return OutbreakListQuery(
    verifiedOnly: false,
    userLat: farm?.latitude,
    userLong: farm?.longitude,
    limit: 15,
  );
});

@immutable
class OutbreakListQuery {
  const OutbreakListQuery({
    required this.verifiedOnly,
    this.userLat,
    this.userLong,
    this.limit = 0,
  });

  final bool verifiedOnly;
  final double? userLat;
  final double? userLong;

  /// 0 means no limit parameter sent to the server.
  final int limit;

  @override
  bool operator ==(Object other) {
    return other is OutbreakListQuery &&
        other.verifiedOnly == verifiedOnly &&
        other.userLat == userLat &&
        other.userLong == userLong &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(verifiedOnly, userLat, userLong, limit);
}

final outbreakListProvider = FutureProvider.autoDispose
    .family<List<OutbreakSummary>, OutbreakListQuery>((ref, query) {
  return ref.read(outbreakRepositoryProvider).listOutbreaks(
        verifiedOnly: query.verifiedOnly,
        userLat: query.userLat,
        userLong: query.userLong,
        limit: query.limit,
      );
});
