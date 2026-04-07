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
  final List<String> selectedCategories;
  final List<String> selectedBrands;
  final double minPrice;
  final double maxPrice;
  final bool isNew;
  final bool isUsed;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool isLoadingMore;

  const RemoteProductsDone(
    List<ProductEntity> allProduct,
    List<ProductEntity> displayedProducts,
    String query,
    this.selectedCategories,
    this.selectedBrands,
    this.minPrice,
    this.maxPrice,
    this.isNew,
    this.isUsed, {
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.isLoadingMore = false,
  }) : super(
        allProducts: allProduct,
        displayedProducts: displayedProducts,
        query: query,
      );

  RemoteProductsDone copyWith({
    List<ProductEntity>? allProduct,
    List<ProductEntity>? displayedProducts,
    String? query,
    List<String>? selectedCategories,
    List<String>? selectedBrands,
    double? minPrice,
    double? maxPrice,
    bool? isNew,
    bool? isUsed,
    int? currentPage,
    int? totalPages,
    bool? hasNextPage,
    bool? isLoadingMore,
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
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class RemoteProductsError extends RemoteProductState {
  const RemoteProductsError(DioException error) : super(error: error);
}
