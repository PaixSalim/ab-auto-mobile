import 'package:auto/brands/domain/entities/brand_entity.dart';
import 'package:auto/core/utils/url_resolver.dart';

class BrandModel extends BrandEntity {
  const BrandModel({super.id, super.name, super.url});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(id: json['id'], name: json['name'], url: resolveUrl(json['url']));
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'url': url};
  }

  @override
  String toString() {
    return 'BrandModel(id: $id, name: $name, url: $url)';
  }
}
