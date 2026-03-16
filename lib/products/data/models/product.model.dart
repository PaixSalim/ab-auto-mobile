import 'package:auto/brands/data/models/brand_model.dart';
import 'package:auto/categories/data/models/category_model.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:auto/products/domain/entities/product_entity.dart';

String _resolveUrl(String url) {
  if (url.startsWith('http')) return url;
  final base = localAPIBaseUrl.replaceAll('/api/v1', '');
  return '$base$url';
}

class ProductModel extends ProductEntity {
  const ProductModel({
    super.id,
    super.name,
    super.slug,
    super.cta,
    super.warranty,
    super.state,
    super.description,
    super.price,
    super.discount,
    CategoryModel? super.category,
    super.features,
    BrandModel? super.brand,
    super.medias,
    super.seller,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    SellerEntity? seller;
    if (json['seller'] != null) {
      final s = json['seller'] as Map<String, dynamic>;
      seller = SellerEntity(
        id: s['id'],
        fullName: s['fullName'],
        email: s['email'],
        phone: s['phone'],
      );
    }
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      cta: json['cta'] ?? '',
      warranty: json['warranty'] ?? '',
      state: json['state'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      brand: json['brand'] != null ? BrandModel.fromJson(json['brand']) : null,
      features: json['features'] != null ? List<String>.from(json['features']) : [],
      medias: json['medias'] != null
          ? List<String>.from(json['medias']).map(_resolveUrl).toList()
          : [],
      seller: seller,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, seller: ${seller?.fullName})';
  }
}
