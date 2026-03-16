import 'package:auto/brands/domain/entities/brand_entity.dart';

class CategoryEntity {
  final int? id;
  final int? items;
  final String? name;
  final String? url;
  final List<BrandEntity>? brands;

  const CategoryEntity({this.id, this.items, this.name, this.url, this.brands});

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      name: json['name'] ?? "",
      url: json['url'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'url': url};
  }
}
