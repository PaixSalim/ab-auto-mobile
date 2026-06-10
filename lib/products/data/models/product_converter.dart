import 'dart:convert';

import 'package:auto/brands/data/models/brand_model.dart';
import 'package:auto/categories/data/models/category_model.dart';
import 'package:auto/products/data/models/product.model.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ProductObjectBox {
  @Id()
  int id = 0;

  int? externalId;
  String? name;
  String? slug;
  String? warranty;
  String? state;
  String? cta;
  String? description;
  double? price;
  double? discount;

  // Stocke les features comme JSON string
  String? featuresJson;
  String? medias;

  String? category;
  String? brand;
  String? categoryId;
  String? brandId;

  ProductObjectBox({
    int? id,
    this.externalId,
    this.name,
    this.slug,
    this.cta,
    this.warranty,
    this.state,
    this.description,
    this.price,
    this.discount,
    this.featuresJson,
    this.medias,
    this.category,
    this.brand,
    this.categoryId,
    this.brandId,
  }) {
    if (id != null && id > 0) this.id = id;
  }

  // Conversion depuis ProductModel
  factory ProductObjectBox.fromModel(ProductEntity model) {
    return ProductObjectBox(
      id: 0,
      externalId: model.id != null ? int.tryParse(model.id!) : null,
      name: model.name,
      slug: model.slug,
      cta: model.cta,
      warranty: model.warranty,
      state: model.state,
      description: model.description,
      price: model.price,
      discount: model.discount,
      featuresJson: jsonEncode(model.features),
      medias: jsonEncode(model.medias),
      category: model.category != null ? jsonEncode(model.category!.toJson()) : null,
      brand: model.brand != null ? jsonEncode(model.brand!.toJson()) : null,
      categoryId: model.category?.id,
      brandId: model.brand?.id,
    );
  }

  // Conversion vers BrandModel
  ProductModel toModel() {
    return ProductModel(
      id: externalId?.toString(),
      name: name,
      slug: slug,
      warranty: warranty,
      state: state,
      cta: cta,
      description: description,
      price: price,
      discount: discount,
      features: getFeatures(),
      medias: getMedias(),
      brand: brand != null ? BrandModel.fromJson(jsonDecode(brand!)) : null,
      category: category != null ? CategoryModel.fromJson(jsonDecode(category!)) : null,
      //medias: product.medias,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, description: $description, features: $featuresJson, price: $price, medias : $medias, )';
  }

  List<String>? getMedias() {
    if (medias == null || medias!.isEmpty) return null;
    try {
      return List<String>.from(jsonDecode(medias!));
    } catch (e) {
            return null;
    }
  }

  List<String>? getFeatures() {
    if (featuresJson == null || featuresJson!.isEmpty) return null;
    try {
      return List<String>.from(jsonDecode(featuresJson!));
    } catch (e) {
            return null;
    }
  }
}
