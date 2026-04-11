import 'package:auto/categories/domain/entities/category_entity.dart';
import '../../../brands/domain/entities/brand_entity.dart';

class SellerEntity {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? city;
  const SellerEntity({this.id, this.fullName, this.email, this.phone, this.city});
}

class ProductEntity {
  final String? id;
  final String? name;
  final String? slug;
  final String? cta;
  final String? warranty;
  final String? state;
  final String? validationStatus;
  final String? description;
  final double? price;
  final double? discount;
  final CategoryEntity? category;
  final CategoryEntity? subCategory;
  final String? subCategoryId;
  final List<String>? features;
  final BrandEntity? brand;
  final List<String>? medias;
  final SellerEntity? seller;
  final String? sellerId;

  const ProductEntity({
    this.id,
    this.name,
    this.slug,
    this.cta,
    this.warranty,
    this.state,
    this.validationStatus,
    this.description,
    this.price,
    this.discount,
    this.category,
    this.subCategory,
    this.subCategoryId,
    this.features,
    this.brand,
    this.medias,
    this.seller,
    this.sellerId,
  });
}
