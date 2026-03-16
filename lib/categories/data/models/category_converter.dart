import 'dart:convert';

import 'package:auto/brands/domain/entities/brand_entity.dart';
import 'package:auto/categories/domain/entities/category_entity.dart';
import 'package:objectbox/objectbox.dart';

import 'category_model.dart';

@Entity()
class CategoryObjectBox {
  @Id()
  int id = 0;

  int? externalId;
  String? name;
  String? url;
  int? items;

  String? brands;

  CategoryObjectBox({
    int? id,
    this.externalId,
    this.name,
    this.url,
    this.brands,
    int? items,
  }) {
    if (id != null && id > 0) this.id = id;
    if (items != null && items > 0) this.items = items;
  }

  factory CategoryObjectBox.fromModel(CategoryEntity model) {
    return CategoryObjectBox(
      id: 0,
      externalId: model.id,
      name: model.name,
      url: model.url,
      items: model.items,
      brands: jsonEncode(model.brands?.map((e) => e.toJson()).toList()),
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $externalId, name: $name, brand: $brands)';
  }

  // Conversion vers CategoryModel
  CategoryModel toModel() {
    final List<BrandEntity> brandList =
        brands != null
            ? (jsonDecode(brands!) as List)
                .map((e) => BrandEntity.fromJson(e))
                .toList()
            : [];

    return CategoryModel(
      id: externalId,
      name: name,
      url: url,
      items: items,
      brands: brandList,
    );
  }
}
