import 'package:flutter/material.dart';

/// Overlays a small red count on the top-end of [child] (e.g. [IconButton]).
/// Uses [Stack] instead of [Badge] so the pill stays visually anchored to the bell,
/// without extra horizontal gap toward the next app bar action.
class UnreadNotificationBadge extends StatelessWidget {
  const UnreadNotificationBadge({
    super.key,
    required this.unreadCount,
    required this.child,
  });

  final int unreadCount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (unreadCount <= 0) return child;
    final label = unreadCount > 99 ? '99+' : '$unreadCount';
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          // Pull left/down so the pill sits on the bell’s upper-right, not in the gap to the next icon.
          right: 4,
          top: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
