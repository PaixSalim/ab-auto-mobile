import 'package:auto/products/domain/entities/media_entity.dart';
import 'package:objectbox/objectbox.dart';

import 'media_model.dart';

@Entity()
class MediaObjectBox {
  @Id()
  int id = 0;

  String? url;
  String? type;

  // Relation avec le produit
  int? productId;

  MediaObjectBox({int? id, this.url, this.type, this.productId}) {
    if (id != null && id > 0) this.id = id;
  }

  // Conversion depuis MediaModel
  factory MediaObjectBox.fromModel(MediaEntity model, {int? productId}) {
    return MediaObjectBox(
      id: model.id,
      url: model.url,
      type: model.type,
      productId: productId,
    );
  }

  // Conversion vers MediaModel
  MediaModel toModel() {
    return MediaModel(id: id, url: url, type: type);
  }
}
