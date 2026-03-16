import 'package:auto/products/domain/entities/media_entity.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Modèle pour représenter un média (image ou vidéo)
class ProductMediaModel {
  final String url;
  final MediaType type;
  final String? thumbnailUrl;

  ProductMediaModel({required this.url, required this.type, this.thumbnailUrl});

  factory ProductMediaModel.image(String url) {
    return ProductMediaModel(url: url, type: MediaType.image);
  }

  // Constructeur pratique pour les vidéos directes (MP4, etc.)
  factory ProductMediaModel.video(String url, {String? thumbnailUrl}) {
    return ProductMediaModel(
      url: url,
      type: MediaType.video,
      thumbnailUrl: thumbnailUrl,
    );
  }
  factory ProductMediaModel.youtube(String url, {String? thumbnailUrl}) {
    return ProductMediaModel(
      url: url,
      type: MediaType.youtube,
      thumbnailUrl: thumbnailUrl ?? _getYoutubeThumbnail(url),
    );
  }

  String? get youtubeId {
    if (type != MediaType.youtube) return null;
    return YoutubePlayer.convertUrlToId(url);
  }

  // Génère une URL de miniature YouTube si aucune n'est fournie
  static String _getYoutubeThumbnail(String youtubeUrl) {
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
    if (videoId == null) return '';
    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

  static List<ProductMediaModel> parseProductMedias(List<String> mediaUrls) {
    return mediaUrls.map((url) {
      if (_isYoutubeUrl(url)) {
        return ProductMediaModel.youtube(url);
      } else {
        return ProductMediaModel.image(url);
      }
    }).toList();
  }

  static bool _isYoutubeUrl(String url) {
    final youtubeRegex = RegExp(r'(youtu\.be\/|youtube\.com\/watch\?v=)');
    return youtubeRegex.hasMatch(url);
  }
}

enum MediaType { image, video, youtube }

// Old version model
class MediaModel extends MediaEntity {
  const MediaModel({super.id, super.url, super.type});

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] ?? 0,
      type: json['name'] ?? "",
      url: json['url'] ?? "",
    );
  }

  @override
  String toString() {
    return "MediaModel(id: $id, type: $type, url: $url";
  }
}
