import 'package:auto/brands/data/models/brand_model.dart';
import 'package:auto/categories/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.id,
    super.items,
    super.name,
    super.url,
    super.brands,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      name: json['name'] ?? "",
      url: json['url'] ?? "",
      items: int.tryParse(json['items']?.toString() ?? "0") ?? 0,
      brands:
          json['brands'] != null
              ? (json['brands'] as List)
                  .map((brand) => BrandModel.fromJson(brand))
                  .toList()
              : [],
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, url: $url, items: $items, brands: $brands';
  }
}
