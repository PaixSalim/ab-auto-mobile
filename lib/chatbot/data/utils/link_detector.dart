import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../presentation/widgets/LinkWidget.dart';
import 'page_detector.dart';

Widget buildRichTextWithWidgets(BuildContext context, String text) {
  // Regex pour détecter les URLs
  final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
  final matches = urlRegex.allMatches(text);

  if (matches.isEmpty) {
    return Text(text, style: const TextStyle(color: Color(0xFF333333)));
  }

  // Diviser le texte en segments (texte normal et liens)
  List<Widget> textSegments = [];
  int lastMatchEnd = 0;

  for (final match in matches) {
    // Ajouter le texte avant le lien
    if (match.start > lastMatchEnd) {
      textSegments.add(
        Text(
          text.substring(lastMatchEnd, match.start),
          style: const TextStyle(color: Color(0xFF333333)),
        ),
      );
    }

    // Extraire l'URL complète
    final url = text.substring(match.start, match.end);

    // Ajouter le widget de lien
    textSegments.add(
      LinkWidget(
        url: url,
        onTap: () => UrlHandler.navigateToPage(context, url),
      ),
    );

    lastMatchEnd = match.end;
  }

  // Ajouter le texte restant après le dernier lien
  if (lastMatchEnd < text.length) {
    textSegments.add(
      Text(
        text.substring(lastMatchEnd),
        style: const TextStyle(color: Color(0xFF333333)),
      ),
    );
  }

  return Wrap(children: textSegments);
}

// Simple link method
class LinkDetector {
  static TextSpan buildTextWithLinks(
    BuildContext context,
    String text, {
    TextStyle? style,
  }) {
    // Regex pour détecter les URLs
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final matches = urlRegex.allMatches(text);

    if (matches.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Ajouter le texte avant le lien
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }

      // Ajouter le lien
      final url = text.substring(match.start, match.end);
      spans.add(
        TextSpan(
          text: url,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
          ),
          recognizer:
              TapGestureRecognizer()
                ..onTap = () async {
                  UrlHandler.navigateToPage(context, url);

                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
        ),
      );

      lastMatchEnd = match.end;
    }

    // Ajouter le texte restant après le dernier lien
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }

    return TextSpan(children: spans);
  }
}
