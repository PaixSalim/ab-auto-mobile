import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/media_model.dart';

Widget buildThumbnail(ProductMediaModel item) {
  if (item.type == MediaType.youtube && item.thumbnailUrl != null) {
    return CachedNetworkImage(
      imageUrl: item.thumbnailUrl!,
      fit: BoxFit.cover,
      progressIndicatorBuilder:
          (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(value: downloadProgress.progress),
          ),
      errorWidget:
          (context, url, error) => const Icon(Icons.error, color: Colors.red),
    );
  } else if (item.type == MediaType.video && item.thumbnailUrl != null) {
    return CachedNetworkImage(
      imageUrl: item.thumbnailUrl!,
      fit: BoxFit.cover,
      progressIndicatorBuilder:
          (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(value: downloadProgress.progress),
          ),
      errorWidget:
          (context, url, error) => const Icon(Icons.error, color: Colors.red),
    );
  } else if (item.type == MediaType.image) {
    return CachedNetworkImage(
      imageUrl: item.url,
      fit: BoxFit.cover,
      progressIndicatorBuilder:
          (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(value: downloadProgress.progress),
          ),
      errorWidget:
          (context, url, error) => const Icon(Icons.error, color: Colors.red),
    );
  } else {
    // Fallback pour les vidéos sans thumbnail
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.play_arrow, color: Colors.white),
    );
  }
}
