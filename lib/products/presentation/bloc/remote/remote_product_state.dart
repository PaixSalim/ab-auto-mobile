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
  final List<String> selectedSubCategories;
  final List<String> selectedBrands;
  final List<String> selectedModels;
  final List<String> selectedYears;
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
    this.selectedSubCategories,
    this.selectedBrands,
    this.selectedModels,
    this.selectedYears,
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

  List<String> get availableModels {
    final models = allProducts?.map((p) => p.model).where((m) => m != null && m.isNotEmpty).map((m) => m!).toSet().toList() ?? [];
    models.sort();
    return models;
  }

  List<String> get availableYears {
    final years = allProducts?.map((p) => p.year).where((y) => y != null && y.isNotEmpty).map((y) => y!).toSet().toList() ?? [];
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<String> get availableBrands {
    final brands = allProducts?.map((p) => p.brand?.name).where((b) => b != null && b.isNotEmpty).map((b) => b!).toSet().toList() ?? [];
    brands.sort();
    return brands;
  }

  RemoteProductsDone copyWith({
    List<ProductEntity>? allProduct,
    List<ProductEntity>? displayedProducts,
    String? query,
    List<String>? selectedCategories,
    List<String>? selectedSubCategories,
    List<String>? selectedBrands,
    List<String>? selectedModels,
    List<String>? selectedYears,
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
      selectedSubCategories ?? this.selectedSubCategories,
      selectedBrands ?? this.selectedBrands,
      selectedModels ?? this.selectedModels,
      selectedYears ?? this.selectedYears,
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
