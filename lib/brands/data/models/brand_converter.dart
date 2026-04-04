import 'package:auto/brands/domain/entities/brand_entity.dart';
import 'package:objectbox/objectbox.dart';

// Import des fichiers générés automatiquement par ObjectBox
import 'brand_model.dart';

// --- ENTITÉS OBJECTBOX ---

@Entity()
class BrandObjectBox {
  @Id()
  int id = 0;

  String? externalId;
  String? name;
  String? url;

  BrandObjectBox({int? id, this.externalId, this.name, this.url}) {
    if (id != null && id > 0) this.id = id;
  }

  // Conversion depuis BrandModel
  factory BrandObjectBox.fromModel(BrandEntity model) {
    return BrandObjectBox(
      id: 0,
      externalId: model.id,
      name: model.name,
      url: model.url,
    );
  }

  // Conversion vers BrandModel
  BrandModel toModel() {
    return BrandModel(id: externalId?.toString(), name: name, url: url);
  }
}
