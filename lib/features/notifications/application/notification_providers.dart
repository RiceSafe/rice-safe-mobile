import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/features/notifications/application/notification_repository_provider.dart';
import 'package:ricesafe_app/features/notifications/data/models/notification_api_models.dart';
import 'package:ricesafe_app/features/outbreak/presentation/providers/outbreak_provider.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';

/// Initial page size for inbox.
const int kNotificationsPageSize = 20;

final notificationsListProvider =
    FutureProvider.autoDispose<List<NotificationDto>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotifications(limit: kNotificationsPageSize, offset: 0);
});

final notificationUnreadCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadCount();
});

/// Distance from the user's saved farm to the outbreak in [referenceId] (km), if API returns it.
final notificationOutbreakDistanceKmProvider =
    FutureProvider.autoDispose.family<double?, String>((ref, referenceId) async {
  if (referenceId.isEmpty) return null;
  final farmAsync = ref.watch(farmLocationProvider);
  final farm = farmAsync.valueOrNull;
  if (farm == null) return null;
  final repo = ref.watch(outbreakRepositoryProvider);
  try {
    final ob = await repo.getById(
      referenceId,
      userLat: farm.latitude,
      userLong: farm.longitude,
    );
    return ob.distance;
  } catch (_) {
    return null;
  }
});
