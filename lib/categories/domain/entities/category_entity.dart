import 'package:auto/brands/domain/entities/brand_entity.dart';

class CategoryEntity {
  final String? id;
  final int? items;
  final String? name;
  final String? url;
  final String? parentId; // ID de la catégorie parente (null si catégorie principale)
  final List<BrandEntity>? brands;
  final List<CategoryEntity>? subCategories; // Sous-catégories

  const CategoryEntity({
    this.id, 
    this.items, 
    this.name, 
    this.url, 
    this.parentId,
    this.brands,
    this.subCategories,
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id']?.toString(),
      name: json['name'] ?? "",
      url: json['url'] ?? "",
      parentId: json['parentId']?.toString() ?? json['parent_id']?.toString(),
      subCategories: json['subCategories'] != null
          ? (json['subCategories'] as List)
              .map((sub) => CategoryEntity.fromJson(sub))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'name': name, 
      'url': url,
      'parentId': parentId,
      'subCategories': subCategories?.map((sub) => sub.toJson()).toList(),
    };
  }
}
