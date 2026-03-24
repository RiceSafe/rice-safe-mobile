import 'package:flutter/material.dart';

/// Small label for post author role from API (`author_role`).
class CommunityRoleBadge extends StatelessWidget {
  const CommunityRoleBadge({super.key, required this.role});

  final String? role;

  static const _farmer = Color(0xFF2E7D32);
  static const _expert = Color(0xFF1565C0);
  static const _admin = Color(0xFFC62828);

  /// Display string: Thai for known roles, otherwise uppercase API value.
  static String displayLabel(String? role) {
    final raw = role?.trim();
    if (raw == null || raw.isEmpty) return '';
    final key = raw.toUpperCase();
    return switch (key) {
      'FARMER' => 'ชาวนา',
      'EXPERT' => 'ผู้เชี่ยวชาญ',
      'ADMIN' => 'ผู้ดูแลระบบ',
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final raw = role?.trim();
    if (raw == null || raw.isEmpty) return const SizedBox.shrink();

    final key = raw.toUpperCase();
    late final Color bg;
    late final Color fg;
    switch (key) {
      case 'FARMER':
        bg = _farmer.withValues(alpha: 0.12);
        fg = _farmer;
      case 'EXPERT':
        bg = _expert.withValues(alpha: 0.12);
        fg = _expert;
      case 'ADMIN':
        bg = _admin.withValues(alpha: 0.12);
        fg = _admin;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade800;
    }

    final label = displayLabel(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }
}

/// Author name with role badge inline immediately after the name.
class CommunityAuthorNameWithRole extends StatelessWidget {
  const CommunityAuthorNameWithRole({
    super.key,
    required this.authorName,
    this.authorRole,
    this.nameFontSize = 16,
  });

  final String authorName;
  final String? authorRole;
  final double nameFontSize;

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: nameFontSize,
    );
    final spans = <InlineSpan>[
      TextSpan(text: authorName, style: nameStyle),
    ];
    final raw = authorRole?.trim();
    if (raw != null && raw.isNotEmpty) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: CommunityRoleBadge(role: authorRole),
          ),
        ),
      );
    }
    return Text.rich(
      TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
