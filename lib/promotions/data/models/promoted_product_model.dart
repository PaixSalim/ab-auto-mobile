import 'package:auto/promotions/domain/entity/promoted_poduct_entity.dart';
import 'package:auto/core/utils/url_resolver.dart';

class PromotedProductModel extends PromotedProductEntity {
  const PromotedProductModel({
    super.id,
    super.productId,
    super.discountPercent,
    super.url,
    super.promoLabel,
    super.promoStartDate,
    super.promoEndDate,
    super.createdAt,
    super.updatedAt,
    super.product,
  });

  factory PromotedProductModel.fromJson(Map<String, dynamic> json) {
    return PromotedProductModel(
      id: json['id']?.toString() ?? "",
      productId: json['productId']?.toString() ?? "",
      discountPercent: json['discountPercent']?.toString() ?? "0",
      url: resolveUrl(json['url'] ?? ""),
      promoLabel: json['promoLabel'] ?? "",
      promoStartDate: json['promoStartDate'] ?? "",
      promoEndDate: json['promoEndDate'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      product: json['product'] != null ? ProductInfoModel.fromJson(json['product']) : null,
    );
  }
}

class ProductInfoModel extends ProductInfo {
  const ProductInfoModel({
    super.id,
    super.name,
    super.slug,
    super.cta,
    super.state,
    super.validationStatus,
    super.rejectionReason,
    super.discount,
    super.features,
    super.categoryId,
    super.brandId,
    super.subCategoryId,
    super.sellerId,
    super.warranty,
    super.description,
    super.price,
    super.createdAt,
    super.updatedAt,
    super.category,
    super.brand,
    super.medias,
  });

  factory ProductInfoModel.fromJson(Map<String, dynamic> json) {
    return ProductInfoModel(
      id: json['id']?.toString() ?? "",
      name: json['name'] ?? "",
      slug: json['slug'] ?? "",
      cta: json['cta'] ?? "",
      state: json['state'] ?? "",
      validationStatus: json['validationStatus'] ?? "",
      rejectionReason: json['rejectionReason'],
      discount: json['discount']?.toString() ?? "0",
      features: json['features'] is List ? (json['features'] as List).join(', ') : json['features']?.toString(),
      categoryId: json['categoryId']?.toString() ?? "",
      brandId: json['brandId']?.toString() ?? "",
      subCategoryId: json['subCategoryId']?.toString() ?? "",
      sellerId: json['sellerId']?.toString() ?? "",
      warranty: json['warranty'] ?? "",
      description: json['description'] ?? "",
      price: json['price']?.toString() ?? "0",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      category: json['category'] != null ? CategoryInfoModel.fromJson(json['category']) : null,
      brand: json['brand'] != null ? BrandInfoModel.fromJson(json['brand']) : null,
      medias: json['medias'] != null 
          ? (json['medias'] as List).map((m) => MediaInfoModel.fromJson(m)).toList()
          : null,
    );
  }
}

class CategoryInfoModel extends CategoryInfo {
  const CategoryInfoModel({
    super.id,
    super.name,
    super.url,
    super.parentId,
    super.createdAt,
    super.updatedAt,
  });

  factory CategoryInfoModel.fromJson(Map<String, dynamic> json) {
    return CategoryInfoModel(
      id: json['id']?.toString() ?? "",
      name: json['name'] ?? "",
      url: json['url'] ?? "",
      parentId: json['parentId']?.toString(),
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
    );
  }
}

class BrandInfoModel extends BrandInfo {
  const BrandInfoModel({
    super.id,
    super.name,
    super.url,
    super.createdAt,
    super.updatedAt,
  });

  factory BrandInfoModel.fromJson(Map<String, dynamic> json) {
    return BrandInfoModel(
      id: json['id']?.toString() ?? "",
      name: json['name'],
      url: json['url'],
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
    );
  }
}

class MediaInfoModel extends MediaInfo {
  const MediaInfoModel({
    super.id,
    super.productId,
    super.type,
    super.url,
    super.createdAt,
    super.updatedAt,
  });

  factory MediaInfoModel.fromJson(Map<String, dynamic> json) {
    return MediaInfoModel(
      id: json['id']?.toString() ?? "",
      productId: json['productId']?.toString() ?? "",
      type: json['type'] ?? "",
      url: resolveUrl(json['url'] ?? ""),
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
    );
  }
}
