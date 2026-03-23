import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricesafe_app/core/error/user_error_message.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ricesafe_app/features/notifications/application/notification_providers.dart';
import 'package:ricesafe_app/features/notifications/application/notification_repository_provider.dart';
import 'package:ricesafe_app/features/notifications/data/models/notification_api_models.dart';
import 'package:ricesafe_app/features/notifications/data/notification_display_localizer.dart';
import 'package:ricesafe_app/main.dart';

/// Inbox for server-pushed notifications (separate from outbreak map tab).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _readAllBusy = false;

  void _invalidateCaches() {
    ref.invalidate(notificationsListProvider);
    ref.invalidate(notificationUnreadCountProvider);
  }

  String _formatTime(DateTime dt) {
    // Numeric date; API timestamps are UTC — show device-local (e.g. Thailand).
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  /// [km] from API (kilometers).
  String _formatDistanceKm(double km) {
    if (km < 1) {
      final m = (km * 1000).round();
      return '$m เมตร';
    }
    return '${km.toStringAsFixed(1)} กม.';
  }

  Future<void> _onTapItem(NotificationDto n) async {
    if (n.isRead) return;
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAsRead(n.id);
      if (!mounted) return;
      _invalidateCaches();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userFacingMessage(
              e,
              contextFallback: 'อัปเดตการแจ้งเตือนไม่สำเร็จ',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _markAllRead() async {
    if (_readAllBusy) return;
    setState(() => _readAllBusy = true);
    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead();
      if (!mounted) return;
      _invalidateCaches();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ทำเครื่องหมายว่าอ่านทั้งหมดแล้ว')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userFacingMessage(
              e,
              contextFallback: 'อัปเดตการแจ้งเตือนไม่สำเร็จ',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _readAllBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('การแจ้งเตือน'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _readAllBusy ? null : _markAllRead,
            child: _readAllBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'อ่านทั้งหมด',
                    style: TextStyle(color: riceSafeGreen),
                  ),
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userFacingMessage(
                    err,
                    contextFallback: 'โหลดการแจ้งเตือนไม่สำเร็จ',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(notificationsListProvider),
                  style: FilledButton.styleFrom(backgroundColor: riceSafeGreen),
                  child: const Text('ลองอีกครั้ง'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return RefreshIndicator(
              color: riceSafeGreen,
              onRefresh: () async {
                ref.invalidate(notificationsListProvider);
                ref.invalidate(notificationUnreadCountProvider);
                await ref.read(notificationsListProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('ยังไม่มีการแจ้งเตือน')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: riceSafeGreen,
            onRefresh: () async {
              ref.invalidate(notificationsListProvider);
              ref.invalidate(notificationUnreadCountProvider);
              await ref.read(notificationsListProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = items[index];
                final unread = !n.isRead;
                final showDistance = n.type == 'OUTBREAK_NEARBY' &&
                    (n.referenceId?.isNotEmpty ?? false);
                final distanceAsync = showDistance
                    ? ref.watch(
                        notificationOutbreakDistanceKmProvider(n.referenceId!),
                      )
                    : null;
                return ListTile(
                  tileColor:
                      unread ? riceSafeGreen.withValues(alpha: 0.06) : null,
                  title: Text(
                    NotificationDisplayLocalizer.titleForDisplay(n),
                    style: TextStyle(
                      fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(NotificationDisplayLocalizer.bodyForDisplay(n)),
                      if (distanceAsync != null)
                        distanceAsync.when(
                          data: (km) {
                            if (km == null) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'ห่างจากแปลงของคุณประมาณ ${_formatDistanceKm(km)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(n.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (unread)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'ยังไม่อ่าน',
                            style: TextStyle(
                              fontSize: 12,
                              color: riceSafeGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () => _onTapItem(n),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
