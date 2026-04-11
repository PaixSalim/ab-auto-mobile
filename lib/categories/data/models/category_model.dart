import 'package:auto/brands/data/models/brand_model.dart';
import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:auto/core/utils/url_resolver.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.id,
    super.items,
    super.name,
    super.url,
    super.parentId,
    super.brands,
    super.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString(),
      name: json['name'] ?? "",
      url: resolveUrl(json['url'] ?? ""),
      items: int.tryParse(json['items']?.toString() ?? "0") ?? 0,
      parentId: json['parentId']?.toString() ?? json['parent_id']?.toString(),
      brands:
          json['brands'] != null
              ? (json['brands'] as List)
                  .map((brand) => BrandModel.fromJson(brand))
                  .toList()
              : [],
      subCategories: json['subCategories'] != null
          ? (json['subCategories'] as List)
              .map((sub) => CategoryModel.fromJson(sub))
              .toList()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'items': items,
      'parentId': parentId,
      'brands': brands?.map((brand) => brand.toJson()).toList(),
      'subCategories': subCategories?.map((sub) => sub.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, url: $url, items: $items, brands: $brands';
  }
}
