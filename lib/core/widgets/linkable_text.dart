import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
// linkify is a direct dependency of flutter_linkify; we need [linkify] + [defaultLinkifiers].
// ignore: depend_on_referenced_packages
import 'package:linkify/linkify.dart'
    show LinkifyElement, TextElement, UrlElement, defaultLinkifiers, linkify;
import 'package:url_launcher/url_launcher.dart';

/// Punctuation often wrapped around URLs in prose; not part of the real URL.
final RegExp _trailingUrlDelimiters =
    RegExp(r'''[\)\]\,;:!?'"}\u201d\u00bb]+$''');

String _stripTrailingUrlDelimiters(String s) {
  final m = _trailingUrlDelimiters.firstMatch(s);
  if (m == null) return s;
  return s.substring(0, m.start);
}

/// Moves trailing delimiters (e.g. `)` after `https://…/)`) out of [UrlElement]s.
List<LinkifyElement> _splitTrailingFromUrls(List<LinkifyElement> elements) {
  final out = <LinkifyElement>[];
  for (final e in elements) {
    if (e is! UrlElement) {
      out.add(e);
      continue;
    }
    final rawUrl = e.url;
    final trimmedUrl = _stripTrailingUrlDelimiters(rawUrl);
    if (trimmedUrl == rawUrl) {
      out.add(e);
      continue;
    }
    if (trimmedUrl.isEmpty) {
      out.add(e);
      continue;
    }
    final suffix = rawUrl.substring(trimmedUrl.length);
    final newDisplay = _stripTrailingUrlDelimiters(e.text);
    out.add(UrlElement(trimmedUrl, newDisplay, e.originText));
    if (suffix.isNotEmpty) {
      out.add(TextElement(suffix));
    }
  }
  return out;
}

/// Renders [text] with tappable http(s) / mailto links; opens externally.
class LinkableText extends StatelessWidget {
  const LinkableText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final linkColor = Theme.of(context).colorScheme.primary;
    final linkStyle = style.copyWith(
      color: linkColor,
      decoration: TextDecoration.underline,
    );

    var elements = linkify(
      text,
      options: const LinkifyOptions(),
      linkifiers: defaultLinkifiers,
    );
    elements = _splitTrailingFromUrls(elements);

    return Text.rich(
      buildTextSpan(
        elements,
        style: style,
        onOpen: (link) => unawaited(_openLink(context, link)),
        useMouseRegion: true,
        linkStyle: linkStyle,
      ),
      textAlign: textAlign,
    );
  }

  static Future<void> _openLink(
    BuildContext context,
    LinkableElement link,
  ) async {
    final uri = Uri.tryParse(link.url);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลิงก์ไม่ถูกต้อง')),
        );
      }
      return;
    }
    final ok = await canLaunchUrl(uri);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเปิดลิงก์นี้ได้')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
