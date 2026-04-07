class PromotedProductEntity {
  final String? id;
  final String? productId;
  final String? discountPercent;
  final String? url;
  final String? promoLabel;
  final String? promoStartDate;
  final String? promoEndDate;
  final String? createdAt;
  final String? updatedAt;
  final ProductInfo? product;

  const PromotedProductEntity({
    this.id,
    this.productId,
    this.discountPercent,
    this.url,
    this.promoLabel,
    this.promoStartDate,
    this.promoEndDate,
    this.createdAt,
    this.updatedAt,
    this.product,
  });
}

class ProductInfo {
  final String? id;
  final String? name;
  final String? slug;
  final String? cta;
  final String? state;
  final String? validationStatus;
  final String? rejectionReason;
  final String? discount;
  final String? features;
  final String? categoryId;
  final String? brandId;
  final String? subCategoryId;
  final String? sellerId;
  final String? warranty;
  final String? description;
  final String? price;
  final String? createdAt;
  final String? updatedAt;
  final CategoryInfo? category;
  final BrandInfo? brand;
  final List<MediaInfo>? medias;

  const ProductInfo({
    this.id,
    this.name,
    this.slug,
    this.cta,
    this.state,
    this.validationStatus,
    this.rejectionReason,
    this.discount,
    this.features,
    this.categoryId,
    this.brandId,
    this.subCategoryId,
    this.sellerId,
    this.warranty,
    this.description,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.brand,
    this.medias,
  });
}

class CategoryInfo {
  final String? id;
  final String? name;
  final String? url;
  final String? parentId;
  final String? createdAt;
  final String? updatedAt;

  const CategoryInfo({
    this.id,
    this.name,
    this.url,
    this.parentId,
    this.createdAt,
    this.updatedAt,
  });
}

class BrandInfo {
  final String? id;
  final String? name;
  final String? url;
  final String? createdAt;
  final String? updatedAt;

  const BrandInfo({
    this.id,
    this.name,
    this.url,
    this.createdAt,
    this.updatedAt,
  });
}

class MediaInfo {
  final String? id;
  final String? productId;
  final String? type;
  final String? url;
  final String? createdAt;
  final String? updatedAt;

  const MediaInfo({
    this.id,
    this.productId,
    this.type,
    this.url,
    this.createdAt,
    this.updatedAt,
  });
}
