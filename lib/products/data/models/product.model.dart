import 'package:auto/brands/data/models/brand_model.dart';
import 'package:auto/categories/data/models/category_model.dart';
import 'package:auto/core/utils/url_resolver.dart';
import 'package:auto/products/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    super.id,
    super.name,
    super.slug,
    super.cta,
    super.warranty,
    super.state,
    super.validationStatus,
    super.description,
    super.model,
    super.year,
    super.price,
    super.discount,
    CategoryModel? super.category,
    CategoryModel? super.subCategory,
    super.subCategoryId,
    super.features,
    BrandModel? super.brand,
    super.medias,
    super.seller,
    super.sellerId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    SellerEntity? seller;
    if (json['seller'] != null) {
      final s = json['seller'] as Map<String, dynamic>;
      seller = SellerEntity(
        id: s['id']?.toString(),
        fullName: s['fullName'],
        email: s['email'],
        phone: s['phone'],
        city: s['city'],
      );
    }
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      cta: json['cta'] ?? '',
      warranty: json['warranty'] ?? '',
      state: json['state'] ?? '',
      validationStatus: json['validationStatus'] ?? '',
      description: json['description'] ?? '',
      model: json['model']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      subCategory: json['subCategory'] != null
          ? CategoryModel.fromJson(json['subCategory'])
          : null,
      subCategoryId: json['subCategoryId']?.toString(),
      brand: json['brand'] != null ? BrandModel.fromJson(json['brand']) : null,
      features: json['features'] != null 
          ? (json['features'] is String 
              ? (json['features'] == '[]' || json['features'] == 'null' ? [] : [json['features'] as String])
              : List<String>.from(json['features'] ?? []))
          : [],
      medias: json['medias'] != null
          ? (json['medias'] as List)
              .map((media) {
                if (media is String) {
                  return resolveUrl(media);
                } else if (media is Map<String, dynamic>) {
                  return resolveUrl(media['url'] ?? '');
                }
                return '';
              })
              .where((url) => url.isNotEmpty)
              .toList()
          : [],
      seller: seller,
      sellerId: json['sellerId']?.toString(),
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, seller: ${seller?.fullName})';
  }
}
