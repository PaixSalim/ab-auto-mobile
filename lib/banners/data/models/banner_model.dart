import 'package:auto/banners/domain/entity/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    super.id,
    super.description,
    super.image,
    super.link,
    super.title,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      description: json['description'] ?? "",
      image: json['image'] ?? "",
      link: json['link'] ?? "",
      title: json['title'],
    );
  }
}
