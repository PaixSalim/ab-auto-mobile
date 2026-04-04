import 'package:auto/promotions/domain/entity/promoted_poduct_entity.dart';
import 'package:auto/core/utils/url_resolver.dart';

class PromotedProductModel extends PromotedProductEntity {
  const PromotedProductModel({
    super.id,
    super.name,
    super.url,
    super.category,
    super.originalPrice,
    super.discountPercent,
    super.promoPrice,
  });

  factory PromotedProductModel.fromJson(Map<String, dynamic> json) {
    return PromotedProductModel(
      id: json['id']?.toString() ?? "",
      name: json['name'] ?? "",
      url: resolveUrl(json['url'] ?? ""),
      category: json['category'] ?? "",
      originalPrice:
          double.tryParse(json['originalPrice']?.toString() ?? "0") ?? 0.0,
      discountPercent:
          double.tryParse(json['discountPercent']?.toString() ?? "0") ?? 0.0,
      promoPrice: double.tryParse(json['promoPrice']?.toString() ?? "0") ?? 0.0,
    );
  }
}
