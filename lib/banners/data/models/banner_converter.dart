import 'package:auto/banners/data/models/banner_model.dart';
import 'package:auto/banners/domain/entity/banner_entity.dart';
import 'package:objectbox/objectbox.dart';

// --- ENTITÉS OBJECTBOX ---

@Entity()
class BannerObjectBox {
  @Id()
  int id = 0;

  int? externalId;
  String? title;
  String? description;
  String? image;
  String? link;

  BannerObjectBox({
    int? id,
    this.externalId,
    this.title,
    this.description,
    this.image,
    this.link,
  }) {
    if (id != null && id > 0) this.id = id;
  }

  // Conversion depuis BannerModel
  factory BannerObjectBox.fromModel(BannerEntity model) {
    return BannerObjectBox(
      id: 0,
      externalId: model.id,
      title: model.title,
      description: model.description,
      image: model.image,
      link: model.link,
    );
  }

  // Conversion vers BrandModel
  BannerModel toModel() {
    return BannerModel(
      id: externalId,
      title: title,
      description: description,
      image: image,
      link: link,
    );
  }
}
