class PromotedProductEntity {
  final int? id;
  final String? name;
  final String? url;
  final String? category;
  final double? originalPrice;
  final double? discountPercent;
  final double? promoPrice;

  const PromotedProductEntity({
    this.id,
    this.name,
    this.url,
    this.category,
    this.originalPrice,
    this.discountPercent,
    this.promoPrice,
  });
}
