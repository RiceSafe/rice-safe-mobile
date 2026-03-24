import 'package:flutter/material.dart';

/// Splits [content] at the trailing `"\n\n📍 "` marker (from create post) and
/// shows the place name like a check-in row.
class PostContentWithLocation extends StatelessWidget {
  const PostContentWithLocation({
    super.key,
    required this.content,
    this.bodyStyle,
    this.locationStyle,
  });

  final String content;
  final TextStyle? bodyStyle;
  final TextStyle? locationStyle;

  static const String _sep = '\n\n📍 ';

  @override
  Widget build(BuildContext context) {
    final idx = content.lastIndexOf(_sep);
    if (idx < 0) {
      return Text(content, style: bodyStyle);
    }
    final body = content.substring(0, idx);
    final location = content.substring(idx + _sep.length).trim();
    if (location.isEmpty) {
      return Text(content, style: bodyStyle);
    }

    final locStyle = locationStyle ??
        bodyStyle?.copyWith(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (body.trim().isNotEmpty) Text(body, style: bodyStyle),
        if (body.trim().isNotEmpty) const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on,
              size: 18,
              color: Colors.red.shade600,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                location,
                style: locStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
