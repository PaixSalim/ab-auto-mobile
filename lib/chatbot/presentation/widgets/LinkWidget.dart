import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkWidget extends StatelessWidget {
  final String url;
  final VoidCallback onTap;

  const LinkWidget({Key? key, required this.url, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getIconForUrl(context, url),
          const SizedBox(width: 4),
          Text(
            _getLinkDisplayText(url),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getIconForUrl(BuildContext context, String url) {
    if (url.contains('/catalogue/view/')) {
      return const Icon(Icons.shopping_bag, size: 16);
    } else if (url.contains('/catalogue')) {
      return const Icon(Icons.category, size: 16);
    } else if (url.contains('/contact')) {
      return GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Row(
          children: [
            Icon(
              LucideIcons.phoneCall,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
            SizedBox(width: 10),
            Text(
              'Nous contacter',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Row(
          children: [
            Icon(
              LucideIcons.phoneCall,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
            SizedBox(width: 10),
            Text(
              'Whatsapp',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getLinkDisplayText(String url) {
    if (url.contains('/catalogue/view/')) {
      return 'Voir le produit';
    } else if (url.contains('/catalogue')) {
      return 'Voir le catalogue';
    } else if (url.contains('/contact')) {
      return 'Nous contacter';
    } else {
      return '';
    }
  }
}
