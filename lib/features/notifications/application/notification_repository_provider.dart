import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/network/dio_provider.dart';
import 'package:ricesafe_app/features/notifications/data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(dio);
});
