import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:dio/dio.dart';

abstract class RemoteProductState {
  final List<ProductEntity>? allProducts;
  final List<ProductEntity>? displayedProducts;
  final DioException? error;
  final String? query;

  const RemoteProductState({
    this.displayedProducts,
    this.allProducts,
    this.query,
    this.error,
  });
  List<Object> get props => [
        if (allProducts != null) allProducts!,
        if (displayedProducts != null) displayedProducts!,
        if (error != null) error!,
      ];
  String? get searchValue => query;
}

class RemoteProductsLoading extends RemoteProductState {
  const RemoteProductsLoading();
}

class RemoteProductsDone extends RemoteProductState {
  final List<int> selectedCategories;
  final List<int> selectedBrands;
  final double minPrice;
  final double maxPrice;
  final bool isNew;
  final bool isUsed;

  const RemoteProductsDone(
    List<ProductEntity> allProduct,
    List<ProductEntity> displayedProducts,
    String query,
    this.selectedCategories,
    this.selectedBrands,
    this.minPrice,
    this.maxPrice,
    this.isNew,
    this.isUsed,
  ) : super(
        allProducts: allProduct,
        displayedProducts: displayedProducts,
        query: query,
      );

  RemoteProductsDone copyWith({
    List<ProductEntity>? allProduct,
    List<ProductEntity>? displayedProducts,
    String? query,
    List<int>? selectedCategories,
    List<int>? selectedBrands,
    double? minPrice,
    double? maxPrice,
    bool? isNew,
    bool? isUsed,
  }) {
    return RemoteProductsDone(
      allProduct ?? this.allProducts!,
      displayedProducts ?? this.displayedProducts!,
      query ?? this.query!,
      selectedCategories ?? this.selectedCategories,
      selectedBrands ?? this.selectedBrands,
      minPrice ?? this.minPrice,
      maxPrice ?? this.maxPrice,
      isNew ?? this.isNew,
      isUsed ?? this.isUsed,
    );
  }
}

class RemoteProductsError extends RemoteProductState {
  const RemoteProductsError(DioException error) : super(error: error);
}
