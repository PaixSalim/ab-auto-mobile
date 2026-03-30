import 'package:auto/core/constants/constants.dart';

/// Résout les URLs relatives en URLs absolues
String resolveUrl(String url) {
  if (url.startsWith('http')) return url;
  if (url.startsWith('/uploads/')) {
    // Pour les uploads, utiliser la base URL sans /api/v1
    final base = localAPIBaseUrl.replaceAll('/api/v1', '');
    return '$base$url';
  }
  return '$localAPIBaseUrl$url';
}
