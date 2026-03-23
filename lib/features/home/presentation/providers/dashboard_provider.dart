import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/network/dio_provider.dart';
import 'package:ricesafe_app/features/home/data/dashboard_repository.dart';
import 'package:ricesafe_app/features/home/data/models/weather_response.dart';
import 'package:ricesafe_app/features/settings/presentation/providers/farm_location_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioProvider));
});

/// Loads weather for persisted farm location. `null` means no farm coordinates saved.
/// Errors surface as [AsyncError] (e.g. 503, network).
final weatherProvider =
    FutureProvider.autoDispose<WeatherResponse?>((ref) async {
  final latLng = await ref.watch(farmLocationProvider.future);
  if (latLng == null) return null;
  return ref.read(dashboardRepositoryProvider).getWeather(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      );
});
